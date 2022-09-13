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
    public float hBound = 0.1f;
    [HideInInspector]
    public float SDF_offset2D = 0.0f;
    //___Slice

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
