using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum SDFTextType
{
    English,
    Chinese,
};

public class SDFText : MonoBehaviour
{
    public SDFTextType language = SDFTextType.English;
    public string content;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //#########################################
    public string GetBakeCode()
    {
        string re = "";
        re += "float d = re;";
        for (int i = 0; i < content.Length; i++)
        {
            if (language == SDFTextType.English)
            {
                char cha = re[i];
                AddBakeEnglish(ref re, cha);
            }
        }
        re += "re = min(re,d);";
        return re;
    }

    void AddBakeEnglish(ref string re, char cha)
    {
        if(cha>=0 && cha<= 127)
        {

        }
        else
        {
            Debug.Log("Unsupported cha: not ASCII code");
        }
    }
}
