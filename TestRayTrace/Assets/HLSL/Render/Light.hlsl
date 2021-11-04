float dis2(float3 p1, float3 p2)
{
	float3 d = p1 - p2;
	return dot(d, d);
}

float3 GetAttenuationed(float3 lightColor, float3 pos, float3 lightPos)
{
	float attenuation = 1.0;
	{
		//float ldis2 = dis2(pos, lightPos);
		//attenuation = 1 / ldis2;
		//attenuation = saturate(attenuation);
	}
	{
		//1.防止距离太近的时候除爆了，衰减亮度需要一个最小值
		//2.可以调整衰减速度，并且保证[0,1]
		//float ldis2 = dis2(pos, lightPos);
		//float d2min = 0.001;
		//float d2max = 50;
		//if (ldis2 > d2min)
		//{
		//	attenuation = (d2max - ldis2) / (d2max - d2min);
		//}
	}
	{
		float d = length(pos - lightPos);
		attenuation = 1 / (1 + 0.2*d + 0.04*d*d);
	}

	return attenuation * lightColor;
}

float rgbSum(float3 color)
{
	return color.r + color.g + color.b;
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