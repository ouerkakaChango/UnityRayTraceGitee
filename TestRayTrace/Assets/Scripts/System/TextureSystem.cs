using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct PBRTexture
{
    public Texture2D albedo,normal,metallic,roughness,ao;
}

//1.outHeight = (TexSample[height].r-0.5)*2*hBound.y
//2.outGrad = normalize(TexSample[grad].xy)
[System.Serializable]
public struct HeightTexture
{
    public Texture2D height, grad;
    public Vector3 bound;
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
