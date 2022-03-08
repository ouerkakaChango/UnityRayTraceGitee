struct Q
{
	float x, y, z, w;
};

// 默认axis已经normalize
Q constructQ(float3 axis, float theta)
{
	Q re;
	re.w = cos(theta / 2);
	float s = sin(theta / 2);
	re.x = axis.x * s;
	re.y = axis.y * s;
	re.z = axis.z * s;
	return re;
}

//默认两vec都已经normalize,并且from!=to
Q QFrom(float3 vecFrom, float3 vecTo)
{
	float cosTheta = dot(vecFrom, vecTo);
	float3 axis = cross(vecFrom, vecTo);
	
	return constructQ(axis, acos(cosTheta));
}

Q Qmul(Q p, Q q)
{
	Q re;
	re.w = p.w * q.w - p.x * q.x - p.y * q.y - p.z * q.z;
	re.x = p.w * q.x + p.x * q.w + p.y * q.z - p.z * q.y;
	re.y = p.w * q.y - p.x * q.z + p.y * q.w + p.z * q.x;
	re.z = p.w * q.z + p.x * q.y - p.y * q.x + p.z * q.w;
	return re;
}

Q QConjugate(Q p)
{
	Q re;
	re.x = -p.x;
	re.y = -p.y;
	re.z = -p.z;
	re.w = p.w;
	return re;
}

float3 QAxis(Q p)
{
	return normalize(float3(p.x, p.y, p.z));
}

float3 Rotate(Q rot, float3 v)
{
	float len = length(v);
	if (len<0.001f)
	{
		return v;
	}
	float3 oriDir = normalize(v);
	Q p;// (oriDir.x, oriDir.y, oriDir.z, 0);
	p.x = oriDir.x;
	p.y = oriDir.y;
	p.z = oriDir.z;
	p.w = 0;

	Q re = Qmul(Qmul(rot,p),QConjugate(rot));
	return QAxis(re) * len;
}

float3 errortoNormalHemisphere(float3 v_local, float3 N)
{
	if (length(N - float3(0, 1, 0)) < 0.001)
	{
		return v_local;
	}
	Q rot = QFrom(float3(0, 1, 0), N);
	return Rotate(rot, v_local);
}

// v must be in z-up coord
float3 toNormalHemisphere(float3 v, float3 N)
{
	float3 helper = float3(1, 0, 0);
	if (abs(N.x) > 0.999) helper = float3(0, 1, 0);
	float3 tangent = normalize(cross(helper, N));
	float3 bitangent = normalize((cross(N, tangent)));
	return v.x*tangent + v.y*bitangent + v.z * N;
}

float3 PFromSpherical(float theta, float phi, float r)
{
	return float3(
		r*sin(theta)*cos(phi),
		r*sin(theta)*sin(phi),
		r*cos(theta)
	);
}

