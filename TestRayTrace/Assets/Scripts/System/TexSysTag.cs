using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum TexTagType
{
    pbrTexture,
    heightTextue,
};

public class TexSysTag : MonoBehaviour
{
    public bool active = true;
    public TexTagType type = TexTagType.pbrTexture;
    [HideInInspector]
    [SerializeField]  public List<PBRTexture> pbrTextures;
    [HideInInspector]
    public List<HeightTexture> heightTextures;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
