using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace XCUnityUtility
{
    public static class MaterialFuncs
    {
        public static void SafeSetMaterial(GameObject obj, Material mat)
        {
            var mr = obj.GetComponent<MeshRenderer>();
            if (mr)
            {
                mr.sharedMaterial = mat;
            }
        }

        public static Material SafeGetMaterial(GameObject obj)
        {
            var mr = obj.GetComponent<MeshRenderer>();
            if (mr)
            {
                return mr.sharedMaterial;
            }
            else
            {
                return null;
            }
        }
    }
}