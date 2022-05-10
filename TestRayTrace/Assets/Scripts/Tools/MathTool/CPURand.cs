using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.XMathFunc;

namespace MathHelper
{
    //https://www.cnblogs.com/gearslogy/p/11717470.html
    //https://github.com/diharaw/GPUPathTracer/blob/master/src/shader/path_tracer_cs.glsl
    public static class CPURand
    {
        public static Vector3 random_in_unit_sphere()
        {
            Vector3 res = random_on_unit_sphere();
            res *= pow(Random.Range(0.0f, 1.0f), 1.0f / 3.0f);
            return res;
        }

        public static Vector3 random_on_unit_sphere()
        {
            float z = Random.Range(-1.0f, 1.0f);
            float t = Random.Range(0.0f, 2.0f * 3.1415926f);
            float r = sqrt(max(0.0f, 1.0f - z * z));
            float x = r * cos(t);
            float y = r * sin(t);
            Vector3 res = new Vector3(x, y, z);
            //res *= pow(Random.Range(0.0f, 1.0f), 1.0f / 3.0f);
            return res;
        }

        public static Vector2 RandDir2D()
        {
            float rad = 2 * Mathf.PI * Random.Range(0.0f, 1.0f);
            return new Vector2(cos(rad), sin(rad));
        }
    }

    public static class LDRand
    {
        static uint rand(ref uint state)
        {
            uint x = state;
            x ^= x << 13;
            x ^= x >> 17;
            x ^= x << 15;
            state = x;
            return x;
        }

        static float random_float_01(ref uint state)
        {
            return (rand(ref state) & 0xFFFFFF) / 16777216.0f;
        }

        static Vector3 random_in_unit_sphere(ref uint state)
        {
            float z = random_float_01(ref state) * 2.0f - 1.0f;
            float t = random_float_01(ref state) * 2.0f * 3.1415926f;
            float r = sqrt(max(0.0f, 1.0f - z * z));
            float x = r * cos(t);
            float y = r * sin(t);
            Vector3 res = new Vector3(x, y, z);
            res *= pow(random_float_01(ref state), 1.0f / 3.0f);
            return res;
        }

        static Vector3 random_on_unit_sphere(ref uint state)
        {
            float z = random_float_01(ref state) * 2.0f - 1.0f;
            float t = random_float_01(ref state) * 2.0f * 3.1415926f;
            float r = sqrt(max(0.0f, 1.0f - z * z));
            float x = r * cos(t);
            float y = r * sin(t);
            Vector3 res = new Vector3(x, y, z);
            //res *= pow(random_float_01(ref state), 1.0f / 3.0f);
            return res;
        }

        public static Vector3 randP_round(Vector3 seed)
        {
            uint stat = (uint)(seed.x) * 1973 + (uint)(seed.y) * 9277 + (uint)(seed.z) * 2699 | 1;

            return random_on_unit_sphere(ref stat);
        }
    }
}
