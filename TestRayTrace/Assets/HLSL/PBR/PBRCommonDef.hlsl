#ifndef PBRCOMMONDEF_HLSL
#define PBRCOMMONDEF_HLSL
#include "../TransferMath/TransferMath.hlsl"

struct Material_PBR
{
	float3 albedo;
	float metallic;
	float roughness;
	float ao;
	float reflective;
	float2 reflect_ST;
	float alpha;
};

void Init(out Material_PBR mat)
{
	mat.albedo = 1;
	mat.metallic = 0;
	mat.roughness = 1;
	mat.ao = 1;
	mat.reflective = 0;
	mat.reflect_ST = float2(1,0);
	mat.alpha = 1;
}

//#######################################################################################

//https://learnopengl-cn.github.io/07%20PBR/03%20IBL/01%20Diffuse%20irradiance/
float3 fresnelSchlickRoughness(float cosTheta, float3 F0, float roughness)
{
	float3 tt = 1.0 - roughness;
	return F0 + (max(tt, F0) - F0) * pow(1.0 - cosTheta, 5.0);
}

float3 IS_SampleSpecularH(float3 N, float roughness, float x1, float x2)
{
	float a = max(0.001f, roughness*roughness);
	float phi = 2 * PI*x1;
	float costheta = sqrt((1 - x2) / (1 + (a*a - 1)*x2));
	float sintheta = sqrt(max(0.0, 1.0 - costheta * costheta)); //·ÀÖ¹¼«ÏÞÎó²î -0.00000x
	float3 H = float3(
		sintheta*cos(phi),
		sintheta*sin(phi),
		costheta);
	return Vec2NormalHemisphere(H, N);
}

float3 IS_SampleDiffuseH(float3 N, float roughness, float x1, float x2)
{
	float theta = 2*PI*x1;
	float phi = PI*(2*x2-1);
	float3 randDir =  float3(
		sin(phi)*cos(theta),
		sin(phi)*sin(theta),
		cos(phi)
	);
	randDir.z = abs(randDir.z);
	return Vec2NormalHemisphere(randDir, N);
}

inline float IS_DiffusePDF(float3 L, HitInfo minHit)
{
	return saturate(dot(minHit.N, L)) / PI;
}

float IS_SpecularPDF(float3 L, float3 H, Material_PBR mat, HitInfo minHit)
{
	float pdf_GGX = 0;
	float a = mat.roughness;
	a = max(0.001f, a*a);

	float m_NH = saturate(dot(minHit.N, H));
	float nomi = a * a * m_NH;
	float m_NH2 = m_NH * m_NH;

	float denom = (m_NH2 * (a*a - 1.0) + 1.0);
	denom = PI * denom * denom;
	pdf_GGX = nomi / denom;
	pdf_GGX /= 4 * dot(L, H);
	pdf_GGX = max(pdf_GGX, 0.001f);
	return pdf_GGX;
}

#endif