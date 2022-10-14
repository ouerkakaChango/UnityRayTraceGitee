using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ShaderEqualision
{
    public static class MaterialCommonDef
    {
    }

    [System.Serializable]
    public struct Material_PBR
    {
        public Color albedo;
        public float metallic;
        public float roughness;
        public float reflective;
        public Vector2 reflect_ST;

        public static Material_PBR DefaultMeta {
            get
            {
                Material_PBR re;
                re.albedo = new Color(1, 1, 1);
                re.metallic = 0.9f;
                re.roughness = 0.1f;
                re.reflective = 0.0f;
                re.reflect_ST = new Vector2(1.0f, 0.0f);
                return re;
            }
        }

        public static Material_PBR Default
        {
            get
            {
                Material_PBR re;
                re.albedo = new Color(1, 1, 1);
                re.metallic = 0.0f;
                re.roughness = 1.0f;
                re.reflective = 0.0f;
                re.reflect_ST = new Vector2(1.0f, 0.0f);
                return re;
            }
        }
    }
}
