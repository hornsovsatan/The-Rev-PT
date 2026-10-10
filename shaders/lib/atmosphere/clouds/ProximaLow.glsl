#if !defined INCLUDE_LIB_CLOUDS_PROXIMA_LOW
#define INCLUDE_LIB_CLOUDS_PROXIMA_LOW

/*
--------------------------------------------------------------------------------
	Low-level (cumulus) clouds ported from Proxima (+ optional enhancements)
	https://github.com/hornsovsatan/proxima
	Source: shaders/lib/atmosphere/clouds/{Common,Shape,Render}.glsl
	Apache License 2.0

	All defaults below = identical to Proxima.
	Mode switch lives in clouds/Common.glsl (CLOUD_CU_MODE == 2 -> PROXIMA_LOW_CLOUDS)
--------------------------------------------------------------------------------
*/

#include "/lib/atmosphere/Common.glsl"
#include "/lib/atmosphere/clouds/Common.glsl"

//======// Options: Quality //====================================================================//

#define PROX_LOW_SAMPLES                 48     // [16 24 32 40 48 56 64 80 96 112 128 160 192 224 256 320 384 448 512]
#define PROX_LOW_SUNLIGHT_SAMPLES        5      // [2 3 4 5 6 7 8 10 12 14 16 20 24 28 32 40 48 56 64]
#define PROX_LOW_SUNLIGHT_DETAIL_SAMPLES 2      // [0 1 2 3 4 5 6 8 10 12 16 20 24 32 64]
#define PROX_LOW_SKYLIGHT_SAMPLES        0      // [0 1 2 3 4 5 6 8 10 12 16 20 24 32]
#define PROX_LOW_LIGHT_DISTANCE          1.0    // [0.5 0.75 1.0 1.25 1.5 2.0 2.5 3.0 4.0]
#define PROX_LOW_DETAIL_DISTANCE         12.0   // [4.0 8.0 12.0 16.0 20.0 24.0 32.0 48.0 64.0 100.0 150.0]
#define PROX_LOW_MAX_DISTANCE            100.0  // [50.0 75.0 100.0 125.0 150.0 200.0 250.0 300.0]
#define PROX_LOW_MIN_TRANSMITTANCE       0.05   // [0.001 0.005 0.01 0.02 0.03 0.05 0.075 0.1]
#define PROX_LOW_DEPTH_MODE              0      // [0 1]
// #define PROX_SHADOW_DETAIL

//======// Options: Shape //======================================================================//

#define PROX_CU_ALTITUDE                 1000.0 // [500.0 600.0 700.0 800.0 900.0 1000.0 1100.0 1200.0 1300.0 1400.0 1500.0 1750.0 2000.0 2500.0 3000.0]
#define PROX_CU_THICKNESS                1500.0 // [500.0 750.0 1000.0 1250.0 1500.0 1750.0 2000.0 2500.0 3000.0 3500.0 4000.0]
#define PROX_CU_COVERAGE                 0.5    // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define PROX_CU_RAIN_COVERAGE            0.75   // [0.0 0.25 0.5 0.75 1.0]
#define PROX_CU_MAP_SCALE                128.0  // [16.0 32.0 48.0 64.0 96.0 128.0 160.0 192.0 256.0 384.0 512.0]
#define PROX_CU_TOP_OFFSET               200.0  // [0.0 50.0 100.0 150.0 200.0 300.0 400.0 500.0 750.0 1000.0]
#define PROX_CU_BASE_NOISE_SCALE 1.0 // [0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.75 0.8 0.9 1.0 1.1 1.25 1.5 1.75 2.0 2.5 3.0 3.5 4.0 5.0 6.0 8.0]
#define PROX_CU_DETAIL_NOISE_SCALE 8.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 12.0 14.0 16.0 20.0 24.0 28.0 32.0 40.0 48.0 64.0]
#define PROX_CU_DETAIL_STRENGTH          1.0    // [0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0]
// #define PROX_CU_CURL_NOISE
#define PROX_CU_CURL_STRENGTH            1.0    // [0.25 0.5 0.75 1.0 1.5 2.0 3.0]
// #define PROX_CU_WISPY_BILLOWY

//======// Options: Medium & Lighting //==========================================================//

#define PROX_LOW_SCATTERING 0.06 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.12 0.15 0.2 0.25 0.3]
#define PROX_LOW_ABSORPTION 0.0 // [0.0 0.001 0.002 0.005 0.01 0.02 0.03 0.05 0.075 0.1]
#define PROX_LOW_PHASE                   0      // [0 1 2]
#define PROX_LOW_DROPLET_SIZE            5.0    // [2.0 3.0 4.0 5.0 6.0 8.0 10.0 12.0 15.0 20.0 30.0 40.0 50.0]
#define PROX_LOW_MS_COUNT                4      // [1 2 3 4 5 6 7 8 10 12 16]
#define PROX_LOW_MS_FALLOFF_S            0.5    // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define PROX_LOW_MS_FALLOFF_E            0.5    // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define PROX_LOW_MS_FALLOFF_P            0.5    // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
// #define PROX_LOW_POWDER
#define PROX_LOW_POWDER_STRENGTH         1.0    // [0.25 0.5 0.75 1.0]
// #define PROX_LOW_NORMALIZE_LIGHT
#define PROX_LOW_SUN_MULT                3.14159 // [0.5 1.0 1.5 2.0 2.5 3.14159 4.0 5.0]
#define PROX_LOW_SKY_MULT 0.25 // [0.0 0.05 0.1 0.15 0.2 0.25 0.5 0.75 1.0 1.5 2.0]
#define PROX_LOW_GROUND_MULT             1.0    // [0.0 0.25 0.5 0.75 1.0 1.5 2.0]
#define PROX_LOW_RAIN_DARKEN             0.5    // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8]
#define PROX_LOW_SHADOW_DARKNESS 1.0 // [0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.5 3.0 4.0 5.0 6.0 8.0]
#define PROX_LOW_MS_ENERGY 1.0 // [0.0 0.25 0.5 0.75 1.0 1.25 1.5 2.0]
#define PROX_LOW_SKY_OCCLUSION 1.0 // [0.5 0.75 1.0 1.5 2.0 2.5 3.0 4.0 6.0 8.0]

//======// Options: Wind //=======================================================================//

#define PROX_LOW_WIND_SPEED              10.0   // [0.0 2.5 5.0 7.5 10.0 15.0 20.0 30.0 40.0 50.0]
#define PROX_LOW_WIND_ANGLE              45.0   // [0.0 15.0 30.0 45.0 60.0 75.0 90.0 120.0 150.0 180.0 210.0 240.0 270.0 300.0 330.0]
#define PROX_LOW_WIND_VERTICAL           0.5    // [0.0 0.25 0.5 0.75 1.0]

//======// Constants //===========================================================================//

const float proxCloudMapExtend        = PROX_CU_MAP_SCALE * 1000.0;
const float proxCumulusThickness      = PROX_CU_THICKNESS;
const float proxCumulusBottomRadius   = planetRadius + PROX_CU_ALTITUDE;
const float proxCumulusTopRadius      = planetRadius + PROX_CU_ALTITUDE + PROX_CU_THICKNESS;
const float proxCumulusTopOffset      = PROX_CU_TOP_OFFSET;

const float proxCumulusScattering     = PROX_LOW_SCATTERING;
const float proxCumulusAbsorption     = PROX_LOW_ABSORPTION;
const float proxCumulusExtinction     = proxCumulusScattering + proxCumulusAbsorption;
const float proxCumulusAlbedo         = proxCumulusScattering / proxCumulusExtinction;

const float proxCloudEpsilon          = 0.001;
const float proxCloudMinTransmittance = PROX_LOW_MIN_TRANSMITTANCE;
const float proxMaxDistance           = PROX_LOW_MAX_DISTANCE * 1000.0;
const float proxDetailDistance        = PROX_LOW_DETAIL_DISTANCE * 1000.0;

const float proxWindAngle             = radians(PROX_LOW_WIND_ANGLE);
const vec3  proxWindDir               = vec3(cos(proxWindAngle), PROX_LOW_WIND_VERTICAL, sin(proxWindAngle));

//======// Samplers //============================================================================//

uniform sampler2D proxCloudMapTex;
uniform sampler3D proxBaseNoiseTex;
uniform sampler3D proxDetailNoiseTex;

//======// Helpers //=============================================================================//

float ProxRemap(float e0, float e1, float x) { return saturate((x - e0) * rcp(e1 - e0)); }
float ProxCurve(float x) { return sqr(x) * (3.0 - 2.0 * x); }

// [Schneider, 2023]. Divisor clamped to avoid NaN when oldMin == 1 (visually identical)
float ProxValueErosion(float value, float oldMin) { return saturate((value - oldMin) / max(1.0 - oldMin, 1e-6)); }

// Triple-lobe HG using Revelation's cloud phase constants
float ProxTripleLobePhase(float mu) {
	float dual = mix(HenyeyGreensteinPhase(mu, cloudForwardG), HenyeyGreensteinPhase(mu, cloudBackwardG), cloudLobeMixer);
	return max(dual, CornetteShanksPhase(mu, cloudSilverG) * cloudSilverI);
}

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
	vec3 windOffset = proxWindDir * PROX_LOW_WIND_SPEED * worldTimeCounter;

	rayPos -= windOffset;
	rayPos -= proxWindDir * proxCumulusTopOffset * heightFraction;
	rayPos.xz += cameraPosition.xz;

	// Sample cloud map
	vec2 cloudMap = texture(proxCloudMapTex, rayPos.xz * rcp(proxCloudMapExtend)).xy;

	// Coverage profile
	float coverage = saturate(mix(cloudMap.x, cloudMap.y + 0.2, sqr(wetness) * PROX_CU_RAIN_COVERAGE) * (4.0 * PROX_CU_COVERAGE));
	if (coverage < 0.25) return 0.0;

	// Vertical profile
	float cloudType = cloudMap.y * sqr(coverage);
	float verticalProfile = ProxGetVerticalProfile(heightFraction, cloudType);

	dimensionalProfile = saturate(verticalProfile * coverage);

	vec3 position = rayPos * (3e-4 * PROX_CU_BASE_NOISE_SCALE);

	// Base shape
	float baseNoise = ProxCurve(texture(proxBaseNoiseTex, position).x);

	float cloudDensity = ProxValueErosion(dimensionalProfile, 1.0 - baseNoise);
	if (cloudDensity < proxCloudEpsilon) return 0.0;

	// Detail erosion
	float detailNoise = 0.5;
	#if !defined PASS_SKY_MAP
	if (detail) {
		position += windOffset * 1e-4;

		#ifdef PROX_CU_CURL_NOISE
			vec3 curl = texture(curlNoise3D, position * 2.0).xyz * 2.0 - 1.0;
			position += curl * (0.05 * PROX_CU_CURL_STRENGTH) * oms(heightFraction);
		#endif

		detailNoise = texture(proxDetailNoiseTex, position * PROX_CU_DETAIL_NOISE_SCALE).x;

		#ifdef PROX_CU_WISPY_BILLOWY
			// Transition from wispy shapes to billowy shapes over height
			detailNoise = mix(1.0 - detailNoise, detailNoise, saturate(heightFraction * 8.0));
		#endif
	}
	#endif
	cloudDensity = ProxRemap(sqr(detailNoise) * sqr(0.7 - heightFraction * 0.5) * PROX_CU_DETAIL_STRENGTH, 1.0, cloudDensity);

	// Density profile
	float densityProfile = sqr(saturate(heightFraction * 4.0));
	densityProfile *= saturate(5.0 - heightFraction * 5.0);
	return approxSqrt(cloudDensity) * densityProfile;
}

//======// Lighting //============================================================================//

float ProxCloudVolumeOpticalDepth(vec3 rayPos, vec3 rayDir, float noise, uint steps, uint detailSteps, float lengthMult) {
	float rSteps = 1.0 / float(steps);
	float rayLength = proxCumulusThickness * lengthMult;
	float stepLength = rayLength * rSteps * rSteps;

	vec3 rayStep = rayDir * stepLength;

	float sumDensity = 0.0;
	for (uint i = 0u; i < steps; ++i) {
		float fi = float(i) + noise;
		vec3 samplePos = rayPos + rayStep * sqr(fi);

		float temp0, temp1;
		float density = ProxCloudVolumeDensity(samplePos, temp0, temp1, i < detailSteps);
		sumDensity += density * fi;
	}

	return proxCumulusExtinction * 2.0 * stepLength * sumDensity;
}

// [Wrenninge et al., 2013], Proxima variant
float ProxCloudMultiScattering(float opticalDepth, float phase, float msVolume) {
	float scatteringFalloff = PROX_LOW_MS_FALLOFF_S;
	float extinctionFalloff = PROX_LOW_MS_FALLOFF_E;

	float scattering = exp2(-rLOG2 * opticalDepth) * phase;
	float energyEstimate = 1.0 + msVolume * (0.5 * PROX_LOW_MS_ENERGY);
	
	for (uint ms = 1u; ms < uint(PROX_LOW_MS_COUNT); ++ms) {
		phase = mix(msVolume * rPI, phase, PROX_LOW_MS_FALLOFF_P) * energyEstimate;
		scattering += exp2(-rLOG2 * extinctionFalloff * opticalDepth) * phase * scatteringFalloff;

		scatteringFalloff *= scatteringFalloff;
		extinctionFalloff *= extinctionFalloff;
	}

	return scattering;
}

//======// Render //==============================================================================//

// Not compiled in the cloud shadow pass (it does not include PhaseLut.glsl)
#if !defined PASS_CLOUD_SM
void RenderProximaLowClouds(vec3 rayDir, vec2 noise, inout vec2 scatteringBase, inout CloudRenderResult result) {
	float moonlightFactor = smoothstep(-0.03, -0.05, sunDirWorld.y);
	vec3 lightDir = sunDirWorld * oms(2.0 * moonlightFactor); // Not normalized, same as Proxima

	#ifdef PROX_LOW_NORMALIZE_LIGHT
		lightDir *= inversesqrt(max(sdot(lightDir), 1e-8)); // Safe normalize (no NaN at the sun/moon switch)
	#endif

	float LdotV = dot(lightDir, rayDir);

	#if PROX_LOW_PHASE == 1
		float phase = SampleCloudPhaseLutScalar(LdotV, CLOUD_PHASE_CU); // Revelation Mie LUT
	#elif PROX_LOW_PHASE == 2
		float phase = ProxTripleLobePhase(LdotV);
	#else
		float phase = HgDrainePhase(LdotV, PROX_LOW_DROPLET_SIZE); // Proxima
	#endif

	vec3 camera = atmosphereViewPos;
	float r = atmosphereViewHeight;
	float mu = rayDir.y;

	bool planetIntersection = RayIntersectPlanetGround(r, mu);

	if ((planetIntersection && r < proxCumulusBottomRadius) || (mu > 0.0 && r > proxCumulusTopRadius)) return;

	vec2 intersection = RaySphericalShellIntersection(r, mu, proxCumulusBottomRadius, proxCumulusTopRadius);
	if (intersection.y <= 0.0) return;

	float withinVolumeSmooth = ProxRemap(proxCumulusThickness + 32.0, proxCumulusThickness - 64.0, abs(r * 2.0 - (proxCumulusBottomRadius + proxCumulusTopRadius)));

	// Proxima: 1e5 - withinVolumeSmooth * 6e4  ==  1e5 * (1 - 0.6 * withinVolumeSmooth)
	float rayLength = clamp(intersection.y - intersection.x, 0.0, proxMaxDistance * (1.0 - 0.6 * withinVolumeSmooth));

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
	float rayDepthIntegral = 0.0;

	vec2 stepScattering = vec2(0.0);
	float transmittance = 1.0;

	for (uint i = 0u; i < raySteps; ++i, rayT += stepSize) {
		vec3 rayPos = camera + rayDir * rayT;

		rayLengthWeighted += rayT * transmittance;
		raySumWeight += transmittance;

		float heightFraction, dimensionalProfile;
		float stepDensity = ProxCloudVolumeDensity(rayPos, heightFraction, dimensionalProfile, rayT < proxDetailDistance);

		if (stepDensity > proxCloudEpsilon) {
			float opticalDepthSun = ProxCloudVolumeOpticalDepth(rayPos, lightDir, noise.y, uint(PROX_LOW_SUNLIGHT_SAMPLES), uint(PROX_LOW_SUNLIGHT_DETAIL_SAMPLES), PROX_LOW_LIGHT_DISTANCE) * PROX_LOW_SHADOW_DARKNESS;
			
			float msVolume = sqr(saturate(stepDensity * 2.0 + dimensionalProfile * 0.5));
			float scatteringSun = ProxCloudMultiScattering(opticalDepthSun, phase, msVolume);

			#ifdef PROX_LOW_POWDER
				// In-scatter probability, slide 92 of [Schneider, 2017] (commented out in Proxima)
				float depthProbability = 0.05 + pow(saturate(stepDensity * 8.0), remap(heightFraction, 0.3, 0.85, 0.5, 2.0));
				float verticalProbability = pow(remap(heightFraction, 0.07, 0.14, 0.1, 1.0), 0.75);
				scatteringSun *= mix(1.0, depthProbability * verticalProbability, PROX_LOW_POWDER_STRENGTH);
			#endif

			#if PROX_LOW_SKYLIGHT_SAMPLES > 0
				// Marched skylight toward the local zenith, slide 85 of [Schneider, 2017]
				vec3 localUp = rayPos * inversesqrt(sdot(rayPos));
				float opticalDepthSky = ProxCloudVolumeOpticalDepth(rayPos, localUp, noise.y, uint(PROX_LOW_SKYLIGHT_SAMPLES), 0u, 1.0) * -rLOG2;
				float scatteringSky = exp2(max(opticalDepthSky, opticalDepthSky * 0.25 - 0.5));
			#else
				// Nubis ambient scattering approximation (Proxima)
				float scatteringSky = approxSqrt(1.0 - dimensionalProfile);
			#endif
						scatteringSky = pow(max(scatteringSky, 0.0), PROX_LOW_SKY_OCCLUSION);
						
			float opticalDepthGround = stepDensity * heightFraction * (proxCumulusThickness * proxCumulusExtinction * -rLOG2);
			float scatteringGround = exp2(max(opticalDepthGround, opticalDepthGround * 0.25 - 0.5)) * rPI * PROX_LOW_GROUND_MULT;

			vec2 scattering = vec2(scatteringSun + scatteringGround * uniformPhase * shadowDirWorld.y,
								   scatteringSky + scatteringGround);

			float stepOpticalDepth = -rLOG2 * proxCumulusExtinction * stepDensity * stepSize;
			float stepTransmittance = exp2(stepOpticalDepth);

			float stepIntegral = transmittance * oms(stepTransmittance);
			stepScattering += scattering * stepIntegral;
			rayDepthIntegral += rayT * stepIntegral;
			transmittance *= stepTransmittance;

			if (transmittance < proxCloudMinTransmittance) break;
		}
	}

	float rawTransmittance = transmittance;
	transmittance = ProxRemap(proxCloudMinTransmittance, 1.0, transmittance);

	if (transmittance < 1.0 - proxCloudEpsilon) {
		vec2 s = stepScattering * proxCumulusAlbedo;

		// Proxima composite: sun * PI * (1 - wetness * 0.5), sky * uniformPhase * PI (= 0.25)
		s.x *= PROX_LOW_SUN_MULT * oms(wetness * PROX_LOW_RAIN_DARKEN);
		s.y *= PROX_LOW_SKY_MULT;

		scatteringBase = s;
		result.transmittance = transmittance;

		#if PROX_LOW_DEPTH_MODE == 1
			// [Hillaire, 2016] weighted by stepIntegral (Revelation method, better TAAU reprojection)
			result.frontDepth = rayDepthIntegral / max(1.0 - rawTransmittance, 1e-6);
		#else
			// Proxima method
			result.frontDepth = rayLengthWeighted / raySumWeight;
		#endif
	}
}
#endif // !PASS_CLOUD_SM

#endif // INCLUDE_LIB_CLOUDS_PROXIMA_LOW
