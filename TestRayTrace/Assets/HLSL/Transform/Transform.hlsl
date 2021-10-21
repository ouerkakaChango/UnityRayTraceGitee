float3 toNormalHemisphere(float3 v, float3 N)
{
	float3 helper = float3(1, 0, 0);
	if (abs(N.x) > 0.999) helper = float3(0, 0, 1);
	float3 tangent = normalize(cross(N, helper));
	float3 bitangent = normalize((cross(N, tangent)));
	return v.x*tangent + v.y*bitangent + v.z * N;
}