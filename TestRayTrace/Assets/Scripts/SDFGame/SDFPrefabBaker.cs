using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Linq;
using CodeTool;
using XFileHelper;
using StringTool;

public class SDFPrefabBaker : MonoBehaviour
{
    public AutoCS autoCS;
    [HideInInspector]
    public int specialID = -1;
    //public List<string> test;
    public string[] extraInclude;
    public string dumpDir;
    [HideInInspector]
    public List<SDFPrefab> prefabs = new List<SDFPrefab>();

    [HideInInspector]
    public string groupPrefabName;
    [HideInInspector]
    public List<SDFBakerTag> groups;
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

        var sdfBlock = AutoCSHelper.GetBlockCode(ref lines, "ObjSDF");
        var contents = CodeHelper.GetBlockOfHead(ref sdfBlock,"if(inx == "+specialID+")");
        if(contents.Count==0)
        {
            Debug.LogError("Target special not exist");
            return;
        }
        CodeHelper.ConvertToNiceLines(ref contents);
        CodeHelper.RemoveComments(ref contents);
        if (contents.Count>1)
        {
            Debug.LogError("Target special not following bake rules:Must be one line function call");
            return;
        }
        else
        {
            var codeLine = contents[0];
            string funcName;
            List<string> paramList;
            Debug.Log("Before 4");
            if (!CodeHelper.ParseFuncLine(codeLine,out funcName, out paramList))
            {
                Debug.LogError("Target special not following bake rules:Must be a func line");
                return;
            }
            else
            {
                Debug.Log("Before 3");
                if (paramList.Count!=2 || paramList[0]!="re" || paramList[1] != "p")
                {
                    Debug.LogError("Target special not following bake rules:Must be XXX(re,p); format");
                    return;
                }
                //now we get a valid func name, find its source in lines
                var funcBlock = AutoCSHelper.GetBlockCode(ref lines, "ExtraSDF");
                Debug.Log("Before 1");
                var funcSource = CodeHelper.GetBlockOfHead(ref funcBlock, "void "+funcName+"(inout float re, in float3 p)",true,true);
                Debug.Log(funcSource.Count);
                if(funcSource.Count==0)
                {
                    Debug.LogError("Cannot find func source");
                    return;
                }
                SDFPrefab pre = new SDFPrefab();
                pre.prefabName = funcName;
                pre.lines = funcSource;
                prefabs.Add(pre);
                //test = funcSource;
                Debug.Log("Bake " + funcName + " done");
            }    
        }
    }

    public void BakeGroup()
    {
        //???
        SDFPrefab pre = new SDFPrefab();
        pre.prefabName = groupPrefabName;
        prefabs.Add(pre);
    }

    public void DumpAllToHLSL()
    {
        string path = FileHelper.FullPath(dumpDir);
        //Debug.Log(path);
        if(!path.EndsWith(".hlsl"))
        {
            Debug.LogError("Not a hlsl!");
            return;
        }
        string fileName = StringHelper.GetFileName(path, ".hlsl");
        //Debug.Log(fileName);
        if (File.Exists(path))
        {
            File.Delete(path);
        }
        File.WriteAllText(path, GetAllPrefabHLSL(fileName));
    }

    public string GetAllPrefabHLSL(string fileName)
    {
        string re = "";
        //head
        string bigName = fileName.ToUpper();
        re += "#ifndef " + bigName + "_HLSL\n";
        re += "#define " + bigName + "_HLSL\n";
        StringHelper.Append(ref re, in extraInclude);
        //mid
        for (int i = 0; i < prefabs.Count; i++)
        {
            StringHelper.Append(ref re, in prefabs[i].lines);
        }
        //tail
        re += "#endif";
        return re;
    }

    public void Clear()
    {
        prefabs.Clear();
    }
}
