cbuffer CameraBuffer : register(b0)
{
    float4x4 viewProjection;
    float3 cameraPosition;
    float time;
};

struct VSInput
{
    float3 position : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct PSInput
{
    float4 position : SV_POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

PSInput VSMain(VSInput input)
{
    PSInput output;
    output.position = mul(float4(input.position, 1.0), viewProjection);
    output.normal = normalize(input.normal);
    output.uv = input.uv;
    return output;
}

float4 PSMain(PSInput input) : SV_TARGET
{
    float light = saturate(dot(input.normal, normalize(float3(0.2, 1.0, 0.3))));
    return float4(input.uv, light, 1.0);
}

