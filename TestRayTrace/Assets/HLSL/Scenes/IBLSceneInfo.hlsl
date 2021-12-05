#include "../PBR/PBR_IBL.hlsl"

Material_PBR GetObjMaterial_PBR(int obj)
{
	//???
	Material_PBR re;
	re.albedo = float3(1, 1, 1);
	re.metallic = 1.0f;
	re.roughness = 0.2f;
	return re;
}