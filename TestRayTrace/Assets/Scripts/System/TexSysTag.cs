using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XUtility;

public enum TexTagType
{
    pbrTexture,
    heightTextue,
    plainTexture,
    envTexture,
};

public class TexSysTag : MonoBehaviour
{
    //public bool active = true;
    public TexTagType type = TexTagType.pbrTexture;
    [HideInInspector]
    [SerializeField]  public List<PBRTexture> pbrTextures = new List<PBRTexture>();
    [HideInInspector]
    public List<HeightTexture> heightTextures = new List<HeightTexture>();
    [HideInInspector]
    public List<NamedTexture> plainTextures = new List<NamedTexture>();
    [HideInInspector]
    public List<EnvTexture> envTextures = new List<EnvTexture>();

    [ReadOnly]
    public int texInx = -1;

    //---SubTex
    public bool useSubTex = false;
    [HideInInspector]
    public int subTexID = 0;
    [HideInInspector]
    public int edgeNum = 4;
    //___SubTex

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //##########################################################
    public Vector4 GetSubInfoVec()
    {
        return new Vector4(edgeNum, edgeNum, subTexID, 0);
    }
}
