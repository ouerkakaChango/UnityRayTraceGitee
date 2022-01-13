using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MathHelper
{
    public static class Vec
    {
        public static bool NearZero(float x)
        {
            return Mathf.Abs(x) < 0.000001f;
        }

        public static Vector3 Divide(in Vector3 v1, in Vector3 v2)
        {
            if (NearZero(v2.x) ||
                NearZero(v2.y) ||
                NearZero(v2.z))
            {
                Debug.LogError("Divide 0 vector3!");
            }
            return new Vector3(v1.x / v2.x, v1.y / v2.y, v1.z / v2.z);
        }

        public static Vector3 Mul(in Vector3 v1, in Vector3 v2)
        {
            return new Vector3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z);
        }

        public static Vector3Int MulToInt3(in Vector3 v1, in Vector3 v2)
        {
            return new Vector3Int((int)(v1.x * v2.x), (int)(v1.y * v2.y), (int)(v1.z * v2.z));
        }

        public static bool gt(in Vector3 a, in Vector3 b)
        {
            return a.x > b.x && a.y > b.y && a.z > b.z;
        }

        public static bool lt(in Vector3 a, in Vector3 b)
        {
            return a.x < b.x && a.y < b.y && a.z < b.z;
        }

        public static float max(float a, float b)
        {
            return a > b ? a : b;
        }

        public static float saturate(float x)
        {
            x = x >= 0 ? x : 0;
            x = x <= 1 ? x : 1;
            return x;
        }

        public static float maxComp(in Vector3 v)
        {
            return max(max(v.x,v.y),v.z);
        }

        public static float dot(in Vector3 a, in Vector3 b)
        {
            return a.x * b.x + a.y * b.y + a.z * b.z;
        }

        public static float length(in Vector3 v)
        {
            return Mathf.Sqrt(dot(v, v));
        }

        public static Vector3 lerp(in Vector3 a, in Vector3 b, float k)
        {
            return a * (1 - k) + b * k;
        }

        public static float pow(float x, float n)
        {
            return Mathf.Pow(x, n);
        }
    }
}