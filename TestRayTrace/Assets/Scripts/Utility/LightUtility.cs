using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LightUtility
{
    public static class LightFuncs
    {
        public static bool IsDirectionalLight(GameObject obj)
        {
            var light = obj.GetComponent<Light>();
            if(light)
            {
                return light.type == LightType.Directional;
            }
            return false;
        }

        public static bool IsPointLight(GameObject obj)
        {
            var light = obj.GetComponent<Light>();
            if (light)
            {
                return light.type == LightType.Point;
            }
            return false;
        }

        public static Vector3 GetLightDir(GameObject obj)
        {
            return obj.transform.forward;
        }

        public static Vector3 GetLightColor(GameObject obj)
        {
            var light = obj.GetComponent<Light>();
            if (light != null)
            {
                float x = light.color.r;
                float y = light.color.g;
                float z = light.color.b;
                float inten = light.intensity;
                return new Vector3(x * inten, y * inten, z * inten);
            }
            else
            {
                var em = obj.GetComponent<SDFEmissiveLightTag>();
                if(em == null)
                {
                    Debug.LogError("not a light");
                    return Vector3.zero;
                }
                float x = em.color.r;
                float y = em.color.g;
                float z = em.color.b;
                float inten = em.intensity;
                return new Vector3(x * inten, y * inten, z * inten);
            }
        }
    }
}