using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct PBRTexture
{
    public Texture2D albedo,normal,metallic,roughness,ao;
}

//�����ռ���������Texture������CameraTrace���Թ�computeShader.SetTexture��ȥ
//���ڿ���Ҫ�ṩVirtualTexture����
public class TextureSystem : MonoBehaviour
{
    public List<PBRTexture> pbrTextures;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
