using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using CodeTool;

public class SDFPrefabBaker : MonoBehaviour
{
    public AutoCS autoCS;
    public int specialID = -1;
    public List<string> test;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //###################################
    public void BakeSpecial()
    {
        if (specialID >= 0)
        {
            Debug.LogError("Not a special! id >= 0");
            return;
        }
        //!!! 现在默认在[1]处是整个场景的cfg
        string path = AutoCS.FullPath(autoCS.cfgs[1]);

        string[] lines = File.ReadAllLines(path);

        var blocks = AutoCSHelper.GetBlockCode(ref lines, "ObjSDF");
        var contents = CodeHelper.GetBlockOfHead(ref blocks,"if(inx == "+specialID+")");
        CodeHelper.ConvertToNiceLines(ref contents);
        CodeHelper.RemoveComments(ref contents);
        if(contents.Count>1)
        {
            Debug.LogError("Target special not following bake rules:Must be one line function call");
            return;
        }
        else
        {
            var codeLine = contents[0];
            string funcName;
            List<string> paramList;
            if(!CodeHelper.ParseFuncLine(codeLine,out funcName, out paramList))
            {
                Debug.LogError("Target special not following bake rules:Must be a func line");
                return;
            }
            else
            {
                if(paramList.Count!=2 || paramList[0]!="re" || paramList[1] != "p")
                {
                    Debug.LogError("Target special not following bake rules:Must be XXX(re,p); format");
                    return;
                }
                //now we get a valid func name, find its source in lines
                Debug.Log("Baking " + funcName);
            }    
        }
    }

}
