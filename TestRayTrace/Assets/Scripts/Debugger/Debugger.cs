using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;

namespace Debugger
{
    public static class Log
    {
        public static string VecStr(Vector3 v)
        {
            var tx = Mathf.Abs(v.x) < 0.000001f ? 0 : v.x;
            var ty = Mathf.Abs(v.y) < 0.000001f ? 0 : v.y;
            var tz = Mathf.Abs(v.z) < 0.000001f ? 0 : v.z;
            return tx + " " + ty + " " + tz;
        }

        public static string VecStr(Vector2 v)
        {
            var tx = Mathf.Abs(v.x) < 0.000001f ? 0 : v.x;
            var ty = Mathf.Abs(v.y) < 0.000001f ? 0 : v.y;
            return tx + " " + ty;
        }

        public static void DebugVec(Vector3 v)
        {
            Debug.Log(VecStr(v));
        }

        public static void DebugVec(Vector2 v)
        {
            Debug.Log(VecStr(v));
        }

        public static void DebugVert(Vertex vert)
        {
            Debug.Log("p: "+VecStr(vert.p) +"\n"+"n: "+ VecStr(vert.n));
        }
    }
}
