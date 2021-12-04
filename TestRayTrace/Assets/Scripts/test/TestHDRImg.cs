using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//https://www.youtube.com/watch?v=3Ic5ZIf74Ls

public class TestHDRImg : MonoBehaviour
{
    public Texture2D hdrImg;
    // Start is called before the first frame update
    void Start()
    {
        int c = 0;
        var colors = hdrImg.GetPixels();
        foreach (var pix in colors)
        {
            if (pix.r > 1)
            {
                Debug.Log(pix);
                c += 1;
            }

            if(c==100)
            {
                break;
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
