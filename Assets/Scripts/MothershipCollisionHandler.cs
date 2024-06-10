using UnityEngine;

public class MothershipCollisionHandler : MonoBehaviour
{
    // This function is called when a particle system collides with the mothership
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

    public void OnCollisionEnter(Collision collision)

    {
        print("Collision");
        if (collision.gameObject.CompareTag("Player") || collision.gameObject.CompareTag("Pimbie"))
        {
            // Destroy the particle system
            Destroy(collision.gameObject);
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
