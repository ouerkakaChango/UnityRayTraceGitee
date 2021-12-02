using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeLogger
{
    public TimeLogger(string funcName_ = "", bool active_ = true)
    {
        funcName = funcName_;
        active = active_;
    }

    public void Start()
    {
        startTime = Time.realtimeSinceStartup;
    }

    public void Log()
    {
        if (active)
        {
            Debug.Log(funcName + " Part" + part + " " + ((Time.realtimeSinceStartup - startTime) * 1000f) + "ms");
            startTime = Time.realtimeSinceStartup;
            part++;
        }
    }

    public void LogSec()
    {
        if (active)
        {
            Debug.Log(funcName + " " + ((Time.realtimeSinceStartup - startTime)) + "s");
            startTime = Time.realtimeSinceStartup;
            part++;
        }
    }

    public float GetSec()
    {
        float re = (Time.realtimeSinceStartup - startTime);
        startTime = Time.realtimeSinceStartup;
        part++;
        return re;
    }

    float startTime;
    int part = 1;
    string funcName = "";
    bool active = true;
}
