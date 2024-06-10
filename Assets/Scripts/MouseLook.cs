using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseLook : MonoBehaviour
{
    public float speed = 5f;
    public float tiltSensitivity = 2f;

    private float rotationX = 0f;
    private float rotationY = 0f;

    // Start is called before the first frame update
    void Start()
    {
        // Lock the cursor to the center of the screen
        Cursor.lockState = CursorLockMode.Locked;
    }

    // Update is called once per frame
    void Update()
    {
        // Get input from the keyboard
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");

        // Create a movement vector based on the input
        Vector3 movement = new Vector3(moveHorizontal, 0.0f, moveVertical);

        // Apply the movement to the spaceship
        transform.Translate(movement * speed * Time.deltaTime, Space.World);

        // Get mouse movement input
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");

        // Calculate rotation based on mouse input
        rotationX -= mouseY * tiltSensitivity;
        rotationY += mouseX * tiltSensitivity;

        // Clamp the rotation to prevent extreme tilting
        rotationX = Mathf.Clamp(rotationX, -45f, 45f);
        rotationY = Mathf.Clamp(rotationY, -45f, 45f);

        // Apply the rotation to the spaceship
        transform.localRotation = Quaternion.Euler(rotationX, rotationY, 0f);
    }
}
