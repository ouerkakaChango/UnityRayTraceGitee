using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum SDFEmissiveRangeType
{
    objList,
    boxRange,
}
    

public class SDFEmissiveLightTag : MonoBehaviour
{
    public Color color = Color.white;
    public float intensity = 1.0f;
    public float fadeScale = 1.0f;
    public SDFEmissiveRangeType rangeType = SDFEmissiveRangeType.objList;

    public List<SDFBakerTag> objs = new List<SDFBakerTag>();

    public Vector3 boxCenter, boxBound;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
