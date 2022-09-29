using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum SDFShadowType
{
    SDFHardShadow,
    SDFSoftShadow,
}

public class SDFLightTag : MonoBehaviour
{
    public bool bakeShadow = true;
    public SDFShadowType shadowType = SDFShadowType.SDFHardShadow;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
