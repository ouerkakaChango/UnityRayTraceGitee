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
    Slice,
    Tex3D,
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
    public float normEplison = 1.0f;
    public int renderMode = 0;
    public SDFShapeType shapeType = SDFShapeType.Normal;
    public List<SDFBooleanTag> booleanTags = new List<SDFBooleanTag>();

    //---Special
    [HideInInspector]
    public int specialID = -1;
    //___Special

    //---Font
    [HideInInspector]
    public char fontCharacter;
    //___Font

    //---Slice
    [HideInInspector]
    public TexSysTag sliceTexTag = null;
    [HideInInspector]
    public float hBound = 0.02f;
    [HideInInspector]
    public float SDF_offset2D = 0.0f;
    //___Slice

    //---Tex3D
    [HideInInspector]
    public TexSysTag tex3DTag = null;
    //___Tex3D

    //---Merge
    [HideInInspector]
    public SDFMergeType mergeType = SDFMergeType.None;
    //___Merge

    [ReadOnly]
    public int objInx;

    //---Extra
    [HideInInspector]
    public bool needExtraCondition = false;
    [HideInInspector]
    public string extraCondition = "";
    //___
    //#######################################################

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
