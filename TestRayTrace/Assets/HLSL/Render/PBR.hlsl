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
	float a = max(0.001f,roughness * roughness);
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

float3 PBR_GGX(Material_PBR param, float3 n, float3 v, float3 l, float3 Li, float diffuseRate=1.0f, float specularRate=1.0f)
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

	float3 Lo = diffuse* diffuseRate + specular* specularRate;
	Lo *= Li * max(dot(n, l), 0);

	return Lo;
}

float3 PBR_GGX_IS(Material_PBR param, float3 n, float3 v, float3 l, float3 Li, float pdf_diffuse, float pdf_specular)
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

	float3 Lo = diffuse/ pdf_diffuse + specular/ pdf_specular;
	Lo *= Li * max(dot(n, l), 0);

	return Lo;
}

float3 IS_SampleDiffuse(float3 N, float roughness, float x1, float x2)
{
	float a = max(0.001f, roughness*roughness);
	float r = sqrt(x1);
	float theta = x2 * 2 * PI;
	float x = r * cos(theta);
	float y = r * sin(theta);
	float z = sqrt(1 - x * x - y * y);
	return toNormalHemisphere(float3(x, y, z), N);
}

float3 IS_SampleSpecular(float3 rayDir, float3 N, float roughness, float x1, float x2)
{
	float a = max(0.001f, roughness*roughness);
	float phi = 2 * PI*x1;
	float costheta = sqrt((1 - x2) / (1 + (a*a - 1)*x2));
	float sintheta = sqrt(max(0.0, 1.0 - costheta * costheta)); //防止极限误差 -0.00000x
	float3 H = float3(
		sintheta*cos(phi),
		sintheta*sin(phi),
		costheta);
	H = toNormalHemisphere(H, N);
	return reflect(rayDir, H);
}


Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	re.metallic = 0.01;
	re.roughness = 0.98;
	int type = 1;
	if (obj == 0)
	{
		re.albedo = float3(1, 1, 1);
		if (type == 1)
		{
			re.metallic = 0.7;
			re.roughness = 0.3;
		}
	}
	else if (obj == 6)
	{
		//lightbox
	}
	else if (obj >= 1 && obj <= OBJNUM-1)
	{
		re.albedo = float3(1, 1, 1);
		if (obj == 3 )
		{
			re.albedo = float3(1, 0, 0);
		}
		else if (obj == 4)
		{
			re.albedo = float3(0, 1, 0);
		}
		if (obj==1 || (obj >= 3 && obj <= OBJNUM - 1 && obj!=5))
		{
			if (type == 1)
			{
				re.metallic = 1.0;
				re.roughness = 0.1;
				//re.metallic = 0.7;
				//re.roughness = 0.3;
			}
		}
		
	}
	else
	{//错误材质色，类似unity中的麦金塔色
		re.albedo = float3(1, 0, 1);
		re.metallic = 0;
		re.roughness = 1;
	}

	//??? test
	if (obj <= 1)
	{
		re.albedo = float3(1, 1, 1);
		re.roughness = 0.1;
		re.metallic = 1.0;
	}

	return re;
}