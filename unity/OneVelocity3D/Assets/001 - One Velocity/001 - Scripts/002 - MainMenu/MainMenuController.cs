using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainMenuController : MonoBehaviour
{
    private void Awake()
    {
        UnityGameManager.Instance.SceneController.ActionPass = true;
    }

}
