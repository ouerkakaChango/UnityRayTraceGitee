using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System;
using System.IO;
using System.Linq;
using UnityEngine;
using static StringTool.StringHelper;
using Debug = UnityEngine.Debug;

using XUtility;
using static Debugger.Log;

//[ExecuteInEditMode]
public class AutoCS : MonoBehaviour
{
    public SDFBakerMgr bakerMgr = null;
    public TextureSystem texSys = null;
    public DynamicValSys dyValSys = null;
    //public MatLibSystem matLibSys = null;
    //0:MatLibSystem
    public List<BaseSystem> systems = new List<BaseSystem>();
    public List<string> templates = new List<string>();
    public List<string> outs = new List<string>();
    public List<string> cfgs = new List<string>();

    public string outTaskFilePath;

    Dictionary<string, List<Vector2Int>> rangeMap = new Dictionary<string, List<Vector2Int>>();

    private void Awake()
    {
        //Generate();
    }

    // Start is called before the first frame update
    void Start()
    {
        //Generate();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //##########################################
    public static string FullPath(string localPath)
    {
        return Application.dataPath + "/" + localPath;
    }

    public void InitOuts()
    {
        outs.Clear();
        for (int i = 0; i < templates.Count; i++)
        {
            outs.Add("");
        }
    }

    string GetTaskString()
    {
        string re = "";
        re += "templates:\n";
        for (int i = 0; i < templates.Count; i++)
        {
            re += FullPath(templates[i]) + "\n";
        }
        re += "\n";
        re += "outs:\n";
        for (int i = 0; i < outs.Count; i++)
        {
            re += FullPath(outs[i]) + "\n";
        }

        re += "\n";
        re += "configs:\n";
        for (int i = 0; i < outs.Count; i++)
        {
            re += FullPath(cfgs[i]) + "\n";
        }
        return re;
    }

    void MakeTaskFile()
    {
        string path = FullPath(outTaskFilePath);
        if (File.Exists(path))
        {
            File.Delete(path);
        }
        File.WriteAllText(path, GetTaskString());
    }

    public void Generate()
    {
        //将templates,outs等写入config
        //调用外部控制台程序exe，进行config+templates => outs

        if(texSys != null)
        {
            texSys.Refresh();
        }
        if(dyValSys!=null)
        {
            dyValSys.Refresh();
        }
        if(bakerMgr!=null)
        {
            bakerMgr.Bake();
            PreCompile();
            for (int i = 0; i < systems.Count; i++)
            {
                systems[i].Refresh();
            }
        }
        else
        {
            Debug.LogError("bakerMgr not give to autoCS");
        }
        MakeTaskFile();
        CallExe();
        ClearMemory();
    }

    void CallExe()
    {
        try
        {
            Process myProcess = new Process();
            myProcess.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
            myProcess.StartInfo.CreateNoWindow = true;
            myProcess.StartInfo.UseShellExecute = false;
            //??? 测试阶段
            {
                //myProcess.StartInfo.FileName = Application.dataPath +"/CmdExe/AutoCS.exe";
                myProcess.StartInfo.FileName = "C:\\Personal\\ParticleToy\\x64\\Debug\\ParticleToy.exe";
            }
            myProcess.StartInfo.WorkingDirectory = Application.dataPath + "/CmdExe";
            myProcess.StartInfo.Arguments = FullPath(outTaskFilePath);
            //Debug.Log(FullPath(outTaskFilePath));
            myProcess.EnableRaisingEvents = true;
            myProcess.Start();
            myProcess.WaitForExit();
            int ExitCode = myProcess.ExitCode;
            UnityEngine.Debug.Log("AutoCS已经运行关闭了 运行返回：" + ExitCode);
        }
        catch (Exception e)
        {
            print(e);
        }
    }

    void PreCompile()
    {
        //Debug.Log("AutoCS PreCompile");
        for (int i=0;i<cfgs.Count;i++)
        {
            PreCompile(FullPath(cfgs[i]), i);
        }
        
    }

    void PreCompile(string path, int fileInx)
    {
        //Debug.Log("###Precompile File: "+ path);
        //1.Load Files to string[]
        var lines = File.ReadAllLines(path);

        rangeMap.Clear();
        rangeMap.Add("ValMaps", new List<Vector2Int>());
        rangeMap.Add("ObjMaterial", new List<Vector2Int>());
        rangeMap.Add("ObjRenderMode", new List<Vector2Int>());
        rangeMap.Add("ObjRender", new List<Vector2Int>());
        rangeMap.Add("DirShadow", new List<Vector2Int>());
        rangeMap.Add("ObjSDF", new List<Vector2Int>());
        rangeMap.Add("ObjUV", new List<Vector2Int>());
        rangeMap.Add("ObjTB", new List<Vector2Int>());
        rangeMap.Add("SpecialObj", new List<Vector2Int>());
        rangeMap.Add("BeforeObjSDF", new List<Vector2Int>());
        rangeMap.Add("TexSys", new List<Vector2Int>());
        rangeMap.Add("DyValSys", new List<Vector2Int>());
        rangeMap.Add("CheckInnerBound", new List<Vector2Int>());
        rangeMap.Add("ObjEnvTex", new List<Vector2Int>());
        rangeMap.Add("TexSys_EnvTexSettings", new List<Vector2Int>());
        rangeMap.Add("ObjNormal", new List<Vector2Int>());

        int exInx = 16;
        rangeMap.Add("ObjMatLib", new List<Vector2Int>());
        rangeMap.Add("ObjImgAttach", new List<Vector2Int>());

        //---extra target sys
        Dictionary<string, int> targetSysDic = new Dictionary<string, int>();
        targetSysDic.Add("ObjMatLib",0);
        targetSysDic.Add("ObjImgAttach", 1);
        //___

        var keyList = rangeMap.Keys.ToList();
        List<Vector2Int> orderList = new List<Vector2Int>();

        for (int i=0;i<lines.Length;i++)
        {
            string line = lines[i];
            line = NiceLine(line);

            bool bDone = false;
            foreach(var key in keyList)
            {
                if (line == "//@@@SDFBakerMgr " + key)
                {
                    rangeMap[key].Add(new Vector2Int(i,-1));
                    bDone = true;
                    break;
                }
            }
            if(bDone)
            {
                continue;
            }

            for (int ikey = 0;ikey < keyList.Count;ikey++)
            {
                string key = keyList[ikey];
                for (int i1 = 0; i1 < rangeMap[key].Count; i1++)
                {
                    if (line == "//@@@" && NeedEnd(rangeMap[key][i1]))
                    {
                        var tt = rangeMap[key][i1];
                        tt.y = i;
                        rangeMap[key][i1] = tt;
                        orderList.Add(new Vector2Int(ikey, i1));
                        break;
                    }
                }
            }
        }

        var keysArr = rangeMap.Keys.ToArray();
        LinesReplaceHelper helper = new LinesReplaceHelper();
        helper.Init(lines);
        for (int i=0;i<orderList.Count;i++)
        {
            var order = orderList[i];
            string key = keyList[order.x];
            var range = rangeMap[key][order.y];
            helper.BeginReplaceRange();
        
            if (key == "ObjSDF" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedSDFs);
            }
            else if (key == "ObjNormal" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedObjNormals);
            }
            else if (key == "ObjUV" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedObjUVs);
            }
            else if (key == "ObjTB" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedObjTBs);
            }
            else if (key == "BeforeObjSDF" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedBeforeSDF);
            }
            else if (key == "ObjEnvTex" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedObjEnvTex);
            }
            else if (key == "CheckInnerBound" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedCheckInnerBound);
            }
            else if (key == "TexSys" && ValidRange(range))
            {
                if (texSys != null)
                {
                    helper.Replace(range, texSys.bakedDeclares);
                }
                else
                {
                    Debug.Log("Warning: no texSys but config has related BLOCK");
                    helper.ClearRange(range);                   
                }
            }
            else if (key == "TexSys_EnvTexSettings" && ValidRange(range))
            {
                if (texSys != null)
                {
                    helper.Replace(range, texSys.bakedEnvTexSettings);
                }
                else
                {
                    Debug.Log("Warning: no texSys but config has related BLOCK");
                    helper.ClearRange(range);
                }
            }
            else if (key == "DyValSys" && ValidRange(range))
            {
                if (dyValSys != null)
                {
                    helper.Replace(range, dyValSys.bakedDeclares);
                }
                else
                {
                    Debug.Log("Warning: no dyValSys but config has related BLOCK");
                    helper.ClearRange(range);
                }
            }
            else if (key == "SpecialObj" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedSpecialObjects);
            }
            else if (key == "ObjMaterial" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedMaterials);
            }
            else if (key == "ObjRenderMode" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedRenderModes);
            }
            else if (key == "ObjRender" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedRenders);
            }
            else if (key == "DirShadow" && ValidRange(range))
            {
                helper.Replace(range, bakerMgr.bakedShadows);
            }
            else if (key == "ValMaps" && ValidRange(range))
            {
                helper.Replace(range, "ObjNum " + bakerMgr.tags.Length);
            }
            else
            {
                for(int i1= exInx; i1<keysArr.Length;i1++)
                {
                    if (key == keysArr[i1] && ValidRange(range))
                    {
                        int sysInx = targetSysDic[key];
                        if (sysInx < 0)
                        {
                            Debug.LogError("Error inx");
                        }
                        else if (sysInx >= systems.Count)
                        {
                            Debug.Log("Warning: system not right: " + key + " .Lines will be cleaned. Check AutoCS system settings");
                            helper.Replace(range, "");
                        }
                        else
                        {
                            helper.Replace(range, systems[sysInx].GetLinesOf(key));
                        }
                    }
                }
            }
        
            helper.EndReplaceRange();
        }

        File.WriteAllLines(path, helper.lines);
    }

    bool NeedEnd(Vector2Int range)
    {
        return range.x >= 0 && range.y == -1;
    }

    bool ValidRange(Vector2Int range)
    {
        return range.x >= 0 && range.y >= range.x;
    }

    void ClearMemory()
    {
        bakerMgr.ClearMemory();
    }
}
