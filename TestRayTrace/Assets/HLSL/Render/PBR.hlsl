float3 fresnelSchlick(float cosTheta, float3 F0)
{
	return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
	float r = (roughness + 1.0);
	float k = (r*r) / 8.0;

	float nom = NdotV;
	float denom = NdotV * (1.0 - k) + k;

	return nom / denom;
}

float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
{
	float NdotV = max(dot(N, V), 0.0);
	float NdotL = max(dot(N, L), 0.0);
	float ggx2 = GeometrySchlickGGX(NdotV, roughness);
	float ggx1 = GeometrySchlickGGX(NdotL, roughness);

	return ggx1 * ggx2;
}

float DistributionGGX(float3 N, float3 H, float roughness)
{
	float a = roughness * roughness;
	float a2 = a * a;
	float NdotH = max(dot(N, H), 0.0);
	float NdotH2 = NdotH * NdotH;

	float nom = a2;
	float denom = (NdotH2 * (a2 - 1.0) + 1.0);
	denom = PI * denom * denom;

	return nom / denom;
}

struct Material_PBR
{
	float3 albedo;
	float metallic;
	float roughness;
};

float3 PBR_GGX(Material_PBR param, float3 n, float3 v, float3 l, float3 Li)
{
	float3 h = normalize(l + v);

	//Calculate F
	float3 F0 = 0.04;
	F0 = lerp(F0, param.albedo, param.metallic);
	float3 F = fresnelSchlick(max(dot(h, v), 0.0), F0);

	//Calculate diffuse
	float3 kD = 1.0 - F;
	float3 diffuse = (1.0 - param.metallic) * kD * param.albedo / PI;

	//Calculate specular
	float G = GeometrySmith(n, v, l, param.roughness);
	float3 nominator;
	float NDF = DistributionGGX(n, h, param.roughness);
	nominator = NDF * G * F;
	float denominator = 4.0 * max(dot(n, v), 0.0) * max(dot(n, l), 0.0) + 0.001;
	float3 specular = nominator / denominator;

	float3 Lo = diffuse + specular;
	Lo *= Li * max(dot(n, l), 0);

	return Lo;
}

Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	int type = 0;
	if (obj == 0)
	{
		re.albedo = float3(1, 1, 1);
		if (type == 0)
		{
			re.metallic = 0.01;
			re.roughness = 0.98;
		}
		else
		{
			re.metallic = 0.7;
			re.roughness = 0.3;
		}
	}
	else if (obj >= 1 && obj <= 5)
	{
		re.albedo = float3(1, 1, 1);
		if (obj == 3)
		{
			re.albedo = float3(1, 0, 0);
		}
		if (obj == 4)
		{
			re.albedo = float3(0, 1, 0);
		}
		if (type == 0)
		{
			re.metallic = 0.01;
			re.roughness = 0.98;
		}
		else
		{
			re.metallic = 0.7;
			re.roughness = 0.3;
		}
	}
	else if (obj == 6)
	{
		//lightbox
	}
	else
	{//错误材质色，类似unity中的麦金塔色
		re.albedo = float3(1, 1, 0);
		re.metallic = 0;
		re.roughness = 1;
	}

	return re;
}

float3 GetObjEmissive(int obj)
{
	if (obj == 6)
	{
		return 50;
	}
	else
	{
		return 0;
	}
}