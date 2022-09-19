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
    //???
    [HideInInspector]
    public List<string> test, test2, test3;
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
        //sdf merge
        //1.先对所有mergedObjects给id
        //2.对于所有spline（逐行处理逻辑）：
        //2.1 将d换成d_[id]
        //2.2 删除re=min(re,d)
        //2.3 其他变量的删重
        //3.对于所有box,换成d_[id]=SDFBox...
        //4.re = min(re,d_[id])所有代码

        List<string>[] linesArr = new List<string>[groups.Count];
        
        for (int i=0;i<groups.Count;i++)
        {
            linesArr[i] = GetObjLines(groups[i].objInx);
            test2 = linesArr[i];
            if (linesArr[i].Count==0)
            {
                Debug.LogError("Can't find obj, id:"+ groups[i].objInx + ". May need Refresh AutoCS?");
                return;
            }
        }

        List<int> idList = new List<int>(); 
        Dictionary<int, List<string>> boxLines = new Dictionary<int, List<string>>();
        Dictionary<int, List<string>> qbLines = new Dictionary<int, List<string>>();
        for(int i=0;i<groups.Count;i++)
        {
            int id = groups[i].objInx;
            if (groups[i].mergeType == SDFMergeType.Box)
            {
                boxLines[id] = linesArr[i];
                idList.Add(id);
            }
            else if (groups[i].mergeType == SDFMergeType.QuadBezier)
            {
                qbLines[id] = linesArr[i];
                idList.Add(id);
            }
        }

        //对于boxlines和qblines，分别进行merge，使用CodeHelper.MergeSDFBox/MergeSDFQuadBezier
        var mergedBoxLines = SDFPrefabMergeHelper.MergeSDFBox(boxLines);
        var mergedQbLines = SDFPrefabMergeHelper.MergeSDFQuadBezier(qbLines);

        var result = mergedBoxLines;
        result.AddRange(mergedQbLines);

        for(int i=0;i<idList.Count;i++)
        {
            int id = idList[i];
            //re = min(re,d[id]);
            result.Add("re = min(re, d"+id+");");
        }

        AddPrefabFuncWrap(ref result, groupPrefabName);

        //???
        test = mergedBoxLines;
        test2 = mergedQbLines;
        test3 = result;
        //___

        SDFPrefab pre = new SDFPrefab();
        pre.prefabName = groupPrefabName;
        pre.lines = result;
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

    public void AddBakeToHLSL()
    {
        //???
        Debug.Log("AddBakeToHLSL");
        string path = FileHelper.FullPath(dumpDir);
        //Debug.Log(path);
        if (!path.EndsWith(".hlsl"))
        {
            Debug.LogError("Not a hlsl!");
            return;
        }
        var orilines = File.ReadAllLines(path);
        var lines = new List<string>(orilines);
        CodeHelper.InsertBefore(ref lines, "#endif", GetAllPrefabHLSLLines());
        File.WriteAllLines(path, lines);
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

    public List<string> GetAllPrefabHLSLLines()
    {
        List<string> re = new List<string>();
        re.Add("");
        for (int i = 0; i < prefabs.Count; i++)
        {
            re.AddRange(prefabs[i].lines);
            re.Add("");
        }
        return re;
    }

    public string GetTotalString()
    {
        var lines = GetAllPrefabHLSLLines();
        string re = "";
        for(int i=0;i<lines.Count;i++)
        {
            re += lines[i];
            re += "\n";
        }
        return re;
    }

    public void Clear()
    {
        prefabs.Clear();
    }

    List<string> GetObjLines(int objInx)
    {
        //!!! 现在默认在[1]处是整个场景的cfg
        string path = AutoCS.FullPath(autoCS.cfgs[1]);

        string[] lines = File.ReadAllLines(path);

        var sdfBlock = AutoCSHelper.GetBlockCode(ref lines, "ObjSDF");
        test = sdfBlock;
        var contents = CodeHelper.GetBlockOfHead(ref sdfBlock, (objInx == 0?"":"else ") +"if(inx == " + objInx + ")");
        if (contents.Count == 0)
        {
            Debug.LogError("Target id sdf not exist,id: "+ objInx);
            if(objInx==0)
            {
                Debug.LogError("May need refreash AutoCS to get objInx?");
            }
            return contents;
        }
        return contents;
    }

    //void SDFPrefab_ASCII_65(inout float re, in float3 p)
    void AddPrefabFuncWrap(ref List<string> lines, string prefabName)
    {
        lines.Insert(0, "{");
        lines.Insert(0, "void " + prefabName + "(inout float re, in float3 p)");
        lines.Add("}");
    }
}
