// No HLSL available - function stub generated

SamplerState LinearSampler : register(s0);
Texture2D<float3> colorTex : register(t0);

struct PSInput
{
	float4 param0 : SV_Position;
	float2 param1 : TEXCOORD0;
	float4 param2 : TEXCOORD1;
};

struct PSOutput
{
	float4 param0 : SV_Target0;
	float4 param1 : SV_Target1;
};

PSOutput mainPS(in PSInput IN)
{
	PSOutput OUT = (PSOutput)0;

	uint screenWidth, screenHeight;
	colorTex.GetDimensions(screenWidth, screenHeight);
	const float2 texelSize = 1.0.xx / float2(screenWidth, screenHeight);

	float2 v_texcoord0 = IN.param1;

	float2 center_offset = v_texcoord0 - float2( 0.5, 0.5 );
	float center_dist = length( center_offset );

	float ca_amount = 0.009;
	//float ca_amount = 0.0;

	int num_colors = 7;//max(3, int(max(screenWidth, screenHeight) * 0.075 * sqrt(ca_amount)));
	float softness = 0.3;

	float3 color_sum = float3(0,0,0);
	float3 res_sum = float3(0,0,0);

	for( int i = 0; i < num_colors; ++i ) {
		float t = float( i ) / ( num_colors - 1 );
		
		const float thresh = softness * 2.0 / 3 + 1.0 / 3;
		float3 color =
			lerp(float3(0,0,1), float3(0,0,0), smoothstep(0, thresh, abs(t - 0.5 / 3)))
		+	lerp(float3(0,1,0), float3(0,0,0), smoothstep(0, thresh, abs(t - 1.5 / 3)))
		+	lerp(float3(1,0,0), float3(0,0,0), smoothstep(0, thresh, abs(t - 2.5 / 3)));

		color_sum += color;

		float offset = float( i - num_colors * 0.5 ) * ca_amount / num_colors;

		float2 sampleUv = float2( 0.5, 0.5 ) + center_offset * ( 1 + offset );
		res_sum += color * colorTex.SampleLevel(LinearSampler, sampleUv, 0 );
	}

	float3 res = res_sum / color_sum;

	OUT.param0 = float4(res, 1.0);
	return OUT;
}
