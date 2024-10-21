using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FlutterUnityIntegration;


/* The GameManager is the central core of the game. It persists all throughout run-time 
 * and stores universal game objects and variables that need to be used in multiple scenes. */
public class UnityGameManager : MonoBehaviour
{
    #region VARIABLES
    //===========================================================
    private static UnityGameManager _instance;

    public static UnityGameManager Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType<UnityGameManager>();

                if (_instance == null)
                    _instance = new GameObject().AddComponent<UnityGameManager>();
            }

            return _instance;
        }
    }


    [field: SerializeField] public List<GameObject> GameMangerObj { get; set; }

    [field: SerializeField] public bool DebugMode { get; set; }
    [SerializeField] private string SceneToLoad;
    [field: SerializeField][field: ReadOnly] public bool CanUseButtons { get; set; }

    [field: Header("CAMERA")]
    [field: SerializeField] public Camera MainCamera { get; set; }
    [field: SerializeField] public Camera MyUICamera { get; set; }

    [field: Header("MISCELLANEOUS SCRIPTS")]
    [field: SerializeField] public UnitySceneController SceneController { get; set; }
    [field: SerializeField] public AnimationsLT AnimationsLT { get; set; }
    [field: SerializeField] public UnityMessageManager UnityMessageManager { get; set; }

    //===========================================================
    #endregion

    #region CONTROLLER FUNCTIONS
    private void Awake()
    {
        if (_instance != null)
        {
            for (int a = 0; a < GameMangerObj.Count; a++)
                Destroy(GameMangerObj[a]);
        }

        for (int a = 0; a < GameMangerObj.Count; a++)
            DontDestroyOnLoad(GameMangerObj[a]);
    }

    private void Start()
    {

        if (DebugMode)
            SceneController.CurrentScene = SceneToLoad;
        else
            SceneController.CurrentScene = "MainMenuScene";
    }
    #endregion
}
