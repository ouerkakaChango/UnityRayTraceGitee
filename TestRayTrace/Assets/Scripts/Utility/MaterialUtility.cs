using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MaterialUtility
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

        public static bool CheckSlot(Material[] mats, int slot)
        {
            if (slot >= mats.Length)
            {
                Debug.LogError("Mat Slot too big");
                return false;
            }
            else if (slot < 0)
            {
                Debug.LogError("Mat Slot neg");
                return false;
            }
            return true;
        }

        public static void SafeSetMaterialSlot(GameObject obj, int slot, Material mat)
        {
            var mr = obj.GetComponent<MeshRenderer>();
            if (mr)
            {
                if (!CheckSlot(mr.sharedMaterials,slot))
                {
                    return;
                }
                var mats = mr.sharedMaterials;
                mats[slot] = mat;
                mr.sharedMaterials = mats;
            }
        }

        public static Material SafeGetMaterialSlot(GameObject obj, int slot)
        {
            var mr = obj.GetComponent<MeshRenderer>();
            if (mr)
            {
                if (!CheckSlot(mr.sharedMaterials, slot))
                {
                    return null;
                }
                return mr.sharedMaterials[slot];
            }
            else
            {
                return null;
            }
        }

        public static void SafeReplaceMaterial(GameObject obj, Material oldm, Material newm)
        {
            var mr = obj.GetComponent<MeshRenderer>();
            if (mr)
            {
                if(mr.sharedMaterial == oldm)
                {
                    mr.sharedMaterial = newm;
                }
            }
        }
    }
}