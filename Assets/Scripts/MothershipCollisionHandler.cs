using UnityEngine;

public class MothershipCollisionHandler : MonoBehaviour
{
    // This function is called when a particle system collides with the mothership
    public float forceMagnitude = 2f;
    private void OnParticleCollision(GameObject other)
    {
        print("Particle");
        // Check if the colliding particle system has the tag "EnemyBullets" or "PlayerBullets"
        if (other.CompareTag("EnemyBullets") || other.CompareTag("PlayerBullet"))
        {
            // Destroy the particle system
            Destroy(other);
        }
    }
    private void OnCollisionEnter(Collision collision)
    {
        print("Collision");
        if (collision.gameObject.CompareTag("Player") || collision.gameObject.CompareTag("Pimbie"))
        {
            print("hii");
            // Get the Rigidbody component from the collided object
            Rigidbody rb = collision.gameObject.GetComponent<Rigidbody>();
            if (rb != null)
            {
                Vector3 collisionNormal = collision.contacts[0].normal;
                Vector3 bounceDirection = collisionNormal; // The normal already points away from the collision

                rb.AddForce(bounceDirection * forceMagnitude);
            }
        }
    }

    void OnTriggerEnter(UnityEngine.Collider other)
    {
        print("Trigger");
        if (other.gameObject.CompareTag("Player") || other.gameObject.CompareTag("Pimbie"))
        {
            // Destroy the particle system
            Destroy(other.gameObject);
        }
    }
}
