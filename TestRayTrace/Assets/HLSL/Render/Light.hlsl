float dis2(float3 p1, float3 p2)
{
	float3 d = p1 - p2;
	return dot(d, d);
}

float3 GetAttenuationed(float3 lightColor, float3 pos, float3 lightPos)
{
	float ldis2 = dis2(pos, lightPos);
	float attenuation = 1.0;
	attenuation = 50 / ldis2;
	attenuation = saturate(attenuation);
	//按光学原理， atten 正比 1/dis2
	//防止距离太近的时候除爆了，衰减亮度需要一个最小值
	//float d2min = 0.01;
	//float d2max = 200000;
	//if (ldis2 > d2min)
	//{
	//	attenuation = (d2max - ldis2) / (d2max - d2min);
	//}
	//attenuation = saturate(attenuation);

	return attenuation * lightColor;
}