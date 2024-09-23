using UnityEngine;
using UnityEngine.EventSystems;

public class SwipeRotate : MonoBehaviour
{
    //======================================================================================================================
    [Header("SWIPE AND ROTATION VARIABLES")]
    [SerializeField] private float rotationSpeed = 1f;
    [SerializeField] private float swipeThreshold = 50f;
    //[SerializeField] private float scaleSpeed = 0.1f;
    //[SerializeField] private float minScale = 0.5f;
    //[SerializeField] private float maxScale = 2f;
    [SerializeField] private float momentum = 0.95f;

    private Vector2 lastTouchPosition;
    private float horizontalSwipeDistance;
    private float horizontalVelocity;
    private bool isHolding = false;

    //======================================================================================================================

    void Update()
    {
        if (!gameObject.activeSelf) return;

        

        if ((Input.touchCount == 1 && !EventSystem.current.IsPointerOverGameObject(Input.GetTouch(0).fingerId))
            || (Input.GetMouseButton(0) && !EventSystem.current.IsPointerOverGameObject()))
        {
            Vector2 touchPosition;
            bool isTouching;

            if (Application.isEditor)
            {
                touchPosition = Input.mousePosition;
                isTouching = Input.GetMouseButton(0);
            }
            else
            {
                Touch touch = Input.GetTouch(0);
                touchPosition = touch.position;
                isTouching = true;
            }

            if (isTouching)
            {
                if (touchPosition.y < Screen.height / 2)
                    return; 
                if (!isHolding)
                {
                    lastTouchPosition = touchPosition;
                    horizontalSwipeDistance = 0f;
                    horizontalVelocity = 0f;
                    isHolding = true;
                }

                Vector2 currentTouchPosition = touchPosition;
                horizontalSwipeDistance += Mathf.Abs(currentTouchPosition.x - lastTouchPosition.x);

                float horizontalRotation = (currentTouchPosition.x - lastTouchPosition.x) * rotationSpeed;
                horizontalVelocity = Mathf.Lerp(horizontalVelocity, horizontalRotation, Time.deltaTime * 10f);

                if (horizontalSwipeDistance > swipeThreshold)
                {
                    transform.Rotate(Vector3.up, -horizontalVelocity, Space.World);
                }

                lastTouchPosition = currentTouchPosition;
            }
        }
        else
        {
            if (isHolding)
            {
                horizontalVelocity = 0f;
                isHolding = false;
            }
            else
            {
                float currentHorizontalVelocity = Mathf.Lerp(horizontalVelocity, 0f, Time.deltaTime * momentum);
                transform.Rotate(Vector3.up, currentHorizontalVelocity, Space.World);
                horizontalVelocity = currentHorizontalVelocity;
            }
        }
    }
}

