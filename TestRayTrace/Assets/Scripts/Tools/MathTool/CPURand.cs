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
    }
}
