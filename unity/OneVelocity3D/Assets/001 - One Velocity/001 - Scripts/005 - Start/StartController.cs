using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StartController : MonoBehaviour
{
    [SerializeField] private StartCore startCore;
    public void Awake()
    {
        UnityGameManager.Instance.SceneController.ActionPass = true;
    }

    public void Start()
    {
        startCore.isGoingUp = true;
    }

    public void Update()
    {
        startCore.TweenFloatLogo();
    }
}
