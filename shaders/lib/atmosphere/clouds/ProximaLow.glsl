#if !defined INCLUDE_LIB_CLOUDS_PROXIMA_LOW
#define INCLUDE_LIB_CLOUDS_PROXIMA_LOW

/*
--------------------------------------------------------------------------------
	Low-level (cumulus) clouds ported 1:1 from Proxima
	https://github.com/hornsovsatan/proxima
	Source: shaders/lib/atmosphere/clouds/{Common,Shape,Render}.glsl
	Apache License 2.0
--------------------------------------------------------------------------------
*/

#include "/lib/atmosphere/Common.glsl"
#include "/lib/atmosphere/clouds/Common.glsl"

//======// Options //=============================================================================//

// PROXIMA_LOW_CLOUDS is derived from CLOUD_CU_MODE == 2 (see /lib/atmosphere/clouds/Common.glsl)

#define PROX_LOW_SAMPLES          48        // [16 24 32 40 48 56 64 80 96 128]
#define PROX_LOW_SUNLIGHT_SAMPLES 5         // [2 3 4 5 6 7 8 10 12 16]
#define PROX_LOW_WIND_SPEED       10.0      // [0.0 5.0 10.0 15.0 20.0 30.0 40.0 50.0]
#define PROX_CU_ALTITUDE          1000.0    // [500.0 750.0 1000.0 1250.0 1500.0 2000.0 2500.0 3000.0]
#define PROX_CU_THICKNESS         1500.0    // [500.0 1000.0 1500.0 2000.0 2500.0 3000.0]
#define PROX_CU_COVERAGE          0.5       // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define PROX_LOW_SUN_MULT         3.14159   // [0.5 1.0 1.5 2.0 2.5 3.14159 4.0]
#define PROX_LOW_SKY_MULT         0.25      // [0.1 0.25 0.5 0.75 1.0]

//======// Constants (Proxima defaults) //========================================================//

const uint  proxMsCount               = 4u;
const float proxMsFalloffA            = 0.5;
const float proxMsFalloffB            = 0.5;
const float proxMsFalloffC            = 0.5;

const float proxCloudMapExtend        = 128e3;
const float proxCumulusThickness      = PROX_CU_THICKNESS;
const float proxCumulusBottomRadius   = planetRadius + PROX_CU_ALTITUDE;
const float proxCumulusTopRadius      = planetRadius + PROX_CU_ALTITUDE + PROX_CU_THICKNESS;
const float proxCumulusTopOffset      = 200.0;

const float proxCumulusExtinction     = 0.06;
const float proxCumulusAlbedo         = 1.0;

const float proxCloudEpsilon          = 0.001;
const float proxCloudMinTransmittance = 0.05;

//======// Samplers //============================================================================//

uniform sampler2D proxCloudMapTex;
uniform sampler3D proxBaseNoiseTex;
uniform sampler3D proxDetailNoiseTex;

//======// Helpers //=============================================================================//

float ProxRemap(float e0, float e1, float x) { return saturate((x - e0) * rcp(e1 - e0)); }
float ProxCurve(float x) { return sqr(x) * (3.0 - 2.0 * x); }
float ProxValueErosion(float value, float oldMin) { return saturate((value - oldMin) / (1.0 - oldMin)); }

//======// Shape //===============================================================================//

float ProxGetVerticalProfile(float heightFraction, float cloudType) {
	float stratus = ProxRemap(0.25, 0.05, heightFraction);
	float stratocumulus = saturate(heightFraction * 6.0) * ProxRemap(0.7, 0.2, heightFraction);
	float cumulus = saturate(heightFraction * 8.0) * ProxRemap(1.0, 0.6, heightFraction);

	float verticalProfile = mix(stratus, stratocumulus, saturate(cloudType * 2.0));
	return mix(verticalProfile, cumulus, saturate(cloudType * 2.0 - 1.0));
}

float ProxCloudVolumeDensity(vec3 rayPos, out float heightFraction, out float dimensionalProfile, bool detail) {
	dimensionalProfile = 0.0;

	float rayRadius = sdot(rayPos); rayRadius *= inversesqrt(rayRadius);
	heightFraction = saturate((rayRadius - proxCumulusBottomRadius) * rcp(proxCumulusThickness));

	// Wind field
	const float windAngle = radians(45.0);
	const vec3 windDir = vec3(cos(windAngle), 0.5, sin(windAngle));
	const vec3 windVelocity = windDir * PROX_LOW_WIND_SPEED;
	vec3 windOffset = windVelocity * worldTimeCounter;

	rayPos -= windOffset;
	rayPos -= windDir * proxCumulusTopOffset * heightFraction;
	rayPos.xz += cameraPosition.xz;

	// Sample cloud map
	vec2 cloudMap = texture(proxCloudMapTex, rayPos.xz * rcp(proxCloudMapExtend)).xy;

	// Coverage profile
	float coverage = saturate(mix(cloudMap.x, cloudMap.y + 0.2, sqr(wetness) * 0.75) * (4.0 * PROX_CU_COVERAGE));
	if (coverage < 0.25) return 0.0;

	// Vertical profile
	float cloudType = cloudMap.y * sqr(coverage);
	float verticalProfile = ProxGetVerticalProfile(heightFraction, cloudType);

	dimensionalProfile = saturate(verticalProfile * coverage);

	vec3 position = rayPos * 3e-4;

	// Base shape
	float baseNoise = ProxCurve(texture(proxBaseNoiseTex, position).x);

	float cloudDensity = ProxValueErosion(dimensionalProfile, 1.0 - baseNoise);
	if (cloudDensity < proxCloudEpsilon) return 0.0;

	// Detail erosion
	float detailNoise = 0.5;
	#if !defined PASS_SKY_MAP
	if (detail) {
		position += windOffset * 1e-4;
		detailNoise = texture(proxDetailNoiseTex, position * 8.0).x;
	}
	#endif
	cloudDensity = ProxRemap(sqr(detailNoise) * sqr(0.7 - heightFraction * 0.5), 1.0, cloudDensity);

	// Density profile
	float densityProfile = sqr(saturate(heightFraction * 4.0));
	densityProfile *= saturate(5.0 - heightFraction * 5.0);
	return approxSqrt(cloudDensity) * densityProfile;
}

//======// Lighting //============================================================================//

float ProxCloudVolumeOpticalDepth(vec3 rayPos, vec3 rayDir, float noise, uint steps) {
	float rSteps = 1.0 / float(steps);
	const float rayLength = proxCumulusThickness;
	float stepLength = rayLength * rSteps * rSteps;

	vec3 rayStep = rayDir * stepLength;

	float sumDensity = 0.0;
	for (uint i = 0u; i < steps; ++i) {
		float fi = float(i) + noise;
		vec3 samplePos = rayPos + rayStep * sqr(fi);

		float temp0, temp1;
		float density = ProxCloudVolumeDensity(samplePos, temp0, temp1, i < 2u);
		sumDensity += density * fi;
	}

	return proxCumulusExtinction * 2.0 * stepLength * sumDensity;
}

// [Wrenninge et al., 2013], Proxima variant
float ProxCloudMultiScattering(float opticalDepth, float phase, float msVolume) {
	float scatteringFalloff = proxMsFalloffA;
	float extinctionFalloff = proxMsFalloffB;

	float scattering = exp2(-rLOG2 * opticalDepth) * phase;
	float energyEstimate = 1.0 + msVolume * 0.5;

	for (uint ms = 1u; ms < proxMsCount; ++ms) {
		phase = mix(msVolume * rPI, phase, proxMsFalloffC) * energyEstimate;
		scattering += exp2(-rLOG2 * extinctionFalloff * opticalDepth) * phase * scatteringFalloff;

		scatteringFalloff *= scatteringFalloff;
		extinctionFalloff *= extinctionFalloff;
	}

	return scattering;
}

//======// Render //==============================================================================//

void RenderProximaLowClouds(vec3 rayDir, vec2 noise, inout vec2 scatteringBase, inout CloudRenderResult result) {
	float moonlightFactor = smoothstep(-0.03, -0.05, sunDirWorld.y);
	vec3 lightDir = sunDirWorld * oms(2.0 * moonlightFactor); // Not normalized, same as Proxima

	float LdotV = dot(lightDir, rayDir);
	float phase = HgDrainePhase(LdotV, 5.0);

	vec3 camera = atmosphereViewPos;
	float r = atmosphereViewHeight;
	float mu = rayDir.y;

	bool planetIntersection = RayIntersectPlanetGround(r, mu);

	if ((planetIntersection && r < proxCumulusBottomRadius) || (mu > 0.0 && r > proxCumulusTopRadius)) return;

	vec2 intersection = RaySphericalShellIntersection(r, mu, proxCumulusBottomRadius, proxCumulusTopRadius);
	if (intersection.y <= 0.0) return;

	float withinVolumeSmooth = ProxRemap(proxCumulusThickness + 32.0, proxCumulusThickness - 64.0, abs(r * 2.0 - (proxCumulusBottomRadius + proxCumulusTopRadius)));

	float rayLength = clamp(intersection.y - intersection.x, 0.0, 1e5 - withinVolumeSmooth * 6e4);

	#if defined PASS_SKY_MAP
		uint raySteps = uint(PROX_LOW_SAMPLES) >> 1u;
		raySteps = uint(float(raySteps) * oms(abs(mu) * 0.5));
	#else
		uint raySteps = uint(PROX_LOW_SAMPLES);
		raySteps = uint(float(raySteps) * mix(oms(abs(mu) * 0.5), 4.0, withinVolumeSmooth));
	#endif

	float stepSize = rayLength * rcp(float(raySteps));
	float rayT = intersection.x + stepSize * noise.x;

	float rayLengthWeighted = 0.0;
	float raySumWeight = 0.0;

	vec2 stepScattering = vec2(0.0);
	float transmittance = 1.0;

	for (uint i = 0u; i < raySteps; ++i, rayT += stepSize) {
		vec3 rayPos = camera + rayDir * rayT;

		rayLengthWeighted += rayT * transmittance;
		raySumWeight += transmittance;

		float heightFraction, dimensionalProfile;
		float stepDensity = ProxCloudVolumeDensity(rayPos, heightFraction, dimensionalProfile, rayT < 12e3);

		if (stepDensity > proxCloudEpsilon) {
			float opticalDepthSun = ProxCloudVolumeOpticalDepth(rayPos, lightDir, noise.y, uint(PROX_LOW_SUNLIGHT_SAMPLES));

			float msVolume = sqr(saturate(stepDensity * 2.0 + dimensionalProfile * 0.5));
			float scatteringSun = ProxCloudMultiScattering(opticalDepthSun, phase, msVolume);

			// Nubis ambient scattering approximation
			float scatteringSky = approxSqrt(1.0 - dimensionalProfile);

			float opticalDepthGround = stepDensity * heightFraction * (proxCumulusThickness * proxCumulusExtinction * -rLOG2);
			float scatteringGround = exp2(max(opticalDepthGround, opticalDepthGround * 0.25 - 0.5)) * rPI;

			vec2 scattering = vec2(scatteringSun + scatteringGround * uniformPhase * shadowDirWorld.y,
								   scatteringSky + scatteringGround);

			float stepOpticalDepth = -rLOG2 * proxCumulusExtinction * stepDensity * stepSize;
			float stepTransmittance = exp2(stepOpticalDepth);

			float stepIntegral = transmittance * oms(stepTransmittance);
			stepScattering += scattering * stepIntegral;
			transmittance *= stepTransmittance;

			if (transmittance < proxCloudMinTransmittance) break;
		}
	}

	transmittance = ProxRemap(proxCloudMinTransmittance, 1.0, transmittance);

	if (transmittance < 1.0 - proxCloudEpsilon) {
		vec2 s = stepScattering * proxCumulusAlbedo;

		// Proxima composite: sun * PI * (1 - wetness * 0.5), sky * uniformPhase * PI (= 0.25)
		s.x *= PROX_LOW_SUN_MULT * oms(wetness * 0.5);
		s.y *= PROX_LOW_SKY_MULT;

		scatteringBase = s;
		result.transmittance = transmittance;
		result.frontDepth = rayLengthWeighted / raySumWeight;
	}
}

#endif // INCLUDE_LIB_CLOUDS_PROXIMA_LOW
