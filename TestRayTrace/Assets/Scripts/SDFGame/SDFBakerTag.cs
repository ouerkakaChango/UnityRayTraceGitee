using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ShaderEqualision;
using XUtility;

public enum SDFShapeType
{
    Normal,
    Special,
    Font,
};

public enum SDFMergeType
{
    None,
    Box,
    QuadBezier,
}

public class SDFBakerTag : MonoBehaviour
{
    //public bool active = true;
    public Material_PBR mat_PBR = Material_PBR.Default;
    public float SDF_offset = 0.0f;
    public int renderMode = 0;
    public SDFShapeType shapeType = SDFShapeType.Normal;
    [HideInInspector]
    public int specialID = -1;
    [HideInInspector]
    public char fontCharacter;
    [HideInInspector]
    public SDFMergeType mergeType = SDFMergeType.None;
    [ReadOnly]
    public int objInx;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
