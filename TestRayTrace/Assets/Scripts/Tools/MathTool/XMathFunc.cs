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

        public static bool NearZero(Vector3 v)
        {
            return NearZero(v.x) && NearZero(v.y) && NearZero(v.z);
        }

        public static float max(float a, float b)
        {
            return a > b ? a : b;
        }

        public static float min(float a, float b)
        {
            return a < b ? a : b;
        }

        public static Vector3 max(Vector3 a, Vector3 b)
        {
            return new Vector3(max(a.x,b.x), max(a.y,b.y), max(a.z,b.z));
        }

        public static Vector3 max(Vector3 a, float b)
        {
            return new Vector3(max(a.x, b), max(a.y, b), max(a.z, b));
        }

        public static float saturate(float x)
        {
            x = x >= 0 ? x : 0;
            x = x <= 1 ? x : 1;
            return x;
        }

        public static float dot(in Vector2 a, in Vector2 b)
        {
            return a.x * b.x + a.y * b.y;
        }

        public static float dot(in Vector3 a, in Vector3 b)
        {
            return a.x * b.x + a.y * b.y + a.z * b.z;
        }

        public static float length(in Vector3 v)
        {
            return v.magnitude;
        }

        public static Vector2 normalize(in Vector2 v)
        {
            return v.normalized;
        }

        public static Vector3 normalize(in Vector3 v)
        {
            return v.normalized;
        }

        public static float lerp(in float a, in float b, float k)
        {
            return a * (1 - k) + b * k;
        }

        public static Vector2 lerp(in Vector2 a, in Vector2 b, float k)
        {
            return a * (1 - k) + b * k;
        }

        public static Vector2 lerp(in Vector2 a, in Vector2 b, Vector2 k)
        {
            return new Vector2(lerp(a.x, b.x, k.x), lerp(a.y, b.y, k.y));
        }

        public static Vector3 lerp(in Vector3 a, in Vector3 b, float k)
        {
            return a * (1 - k) + b * k;
        }

        public static float pow(float x, float n)
        {
            return Mathf.Pow(x, n);
        }

        public static Vector2 pow(Vector2 x, Vector2 n)
        {
            return  new Vector2(Mathf.Pow(x.x, n.x), Mathf.Pow(x.y, n.y));
        }

        public static Vector3 pow(Vector3 x, float n)
        {
            return new Vector3(Mathf.Pow(x.x, n), Mathf.Pow(x.y, n), Mathf.Pow(x.z, n));
        }

        public static float sqrt(float x)
        {
            return Mathf.Sqrt(x);
        }

        public static float cos(float x)
        {
            return Mathf.Cos(x);
        }

        public static float acos(float x)
        {
            return Mathf.Acos(x);
        }

        public static float sin(float x)
        {
            return Mathf.Sin(x);
        }

        public static float fmod(float x, float y)
        {
            return  x - (int)(x / y) * y;
        }

        public static float abs(float x)
        {
            return x >= 0 ? x : -x;
        }

        public static Vector2 abs(in Vector2 v)
        {
            return new Vector2(abs(v.x), abs(v.y));
        }

        public static Vector3 abs(in Vector3 v)
        {
            return new Vector3(abs(v.x), abs(v.y), abs(v.z));
        }

        public static float floor(float x)
        {
            return Mathf.Floor(x);
        }

        public static float clamp(float x, float min, float max)
        {
            if (x < min)
            {
                return min;
            }
            if (x > max)
            {
                return max;
            }
            return x;
        }

        public static float sign(float x)
        {
            return x >= 0 ? 1.0f : -1.0f;
        }

        public static Vector2 sign(Vector2 v)
        {
            return new Vector2(sign(v.x), sign(v.y));
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

        public static bool equal(float a, float b)
        {
            return abs(a - b) < 0.000001f;
        }

        public static float quadrance(in Vector3 v)
        {
            return v.sqrMagnitude;
        }
    }
}
