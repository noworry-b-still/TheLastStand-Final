using UnityEngine;

public class EnemyMothershipAppear : MonoBehaviour
{
    [SerializeField] private Vector3 targetPosition = new Vector3(-3051, 54, 8771); // Target position for the spaceship to appear
    public float appearDuration = 3f; // Duration for the spaceship to appear

    private Vector3 initialPosition; // Initial position of the spaceship
    private float appearStartTime; // Time when the spaceship starts to appear
    private bool hasReachedTarget = false; // Flag to track if the spaceship has reached the target position

    // Reference to the AudioSource component
    private AudioSource audioSource;

    void Start()
    {
        // Save the initial position of the spaceship
        initialPosition = transform.position;

        // Start the appear animation
        appearStartTime = Time.time;

        // Get the AudioSource component attached to the same GameObject
        audioSource = GetComponent<AudioSource>();
    }

    void Update()
    {
        // Calculate the progress of the appear animation (0 to 1)
        float progress = Mathf.Clamp01((Time.time - appearStartTime) / appearDuration);

        // Apply ease-in interpolation to the progress
        float easedProgress = EaseIn(progress);

        // Move the spaceship towards the target position
        transform.position = Vector3.Lerp(initialPosition, targetPosition, easedProgress);

        // Check if the spaceship has reached the target position
        if (!hasReachedTarget && progress >= 1f)
        {
            // Set the flag to true to prevent repeated playing of the audio clip
            hasReachedTarget = true;

            // Check if an audio clip is assigned to the AudioSource component
            if (audioSource != null && audioSource.clip != null)
            {
                // Play the audio clip
                audioSource.Play();
            }
            else
            {
                Debug.LogError("No audio clip assigned to the AudioSource component!");
            }
        }
    }

    // Ease-in interpolation function
    float EaseIn(float t)
    {
        return t * t * t;
    }
}
