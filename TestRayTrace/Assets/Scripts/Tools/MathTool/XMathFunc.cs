using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MathHelper
{
    public static class XMathFunc
    {
        public static bool NearZero(float x)
        {
            return Mathf.Abs(x) < 0.000001f;
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

        public static float sqrt(float x)
        {
            return Mathf.Sqrt(x);
        }

        public static float cos(float x)
        {
            return Mathf.Cos(x);
        }

        public static float sin(float x)
        {
            return Mathf.Sin(x);
        }

        //#######################################################
        public static bool gt(in Vector3 a, in Vector3 b)
        {
            return a.x > b.x && a.y > b.y && a.z > b.z;
        }

        public static bool lt(in Vector3 a, in Vector3 b)
        {
            return a.x < b.x && a.y < b.y && a.z < b.z;
        }

        public static float maxComp(in Vector3 v)
        {
            return max(max(v.x, v.y), v.z);
        }
    }
}
