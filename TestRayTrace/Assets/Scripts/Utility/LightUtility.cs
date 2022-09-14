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
            float x = light.color.r;
            float y = light.color.g;
            float z = light.color.b;
            return new Vector3(x * light.intensity, y * light.intensity, z * light.intensity);
        }
    }
}