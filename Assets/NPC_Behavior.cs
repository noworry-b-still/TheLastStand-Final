using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NPC_Behavior : MonoBehaviour
{
    public enum FSMStates
    {
        Idle,
        Wander,
        Run,
        Dead
    }

    public FSMStates currentState;

    public GameObject explosionPrefab;
    GameObject[] wanderPoints;
    Vector3 nextDestination;
    public GameObject player;
    public float fleeDistance = 50;
    public float NPC_Speed = 20;
    float elapsedTime = 0;
    float timeInstance = 0;
    float distanceToPlayer;
    int currentDestinationIndex = 0;
    Vector3 runDirection;
    void Start()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        wanderPoints = GameObject.FindGameObjectsWithTag("WanderPoint");
        currentState = FSMStates.Wander;
        FindNextPoint();
    }

    // Update is called once per frame
    void Update()
    {
        distanceToPlayer = Vector3.Distance(transform.position, player.transform.position);
        //Debug.Log(currentState);
        switch (currentState)
        {
            case FSMStates.Idle:
                updateIdleState();
                break;
            case FSMStates.Wander:
                updateWanderState();
                break;
            case FSMStates.Run:
                updateRunState();
                break;
            case FSMStates.Dead:
                updateDeadState();
                break;

        }

        elapsedTime += Time.deltaTime;
    }

    void updateIdleState()
    {
        float difference = elapsedTime - timeInstance;
        if (difference > 5f)
        {
            currentState = FSMStates.Wander;
        }
        else if (distanceToPlayer <= fleeDistance)
        {
            runDirection = (player.transform.position - transform.position).normalized * -1;
            currentState = FSMStates.Run;
        }
        // Idle at each wander point for 5 seconds
    }


    void updateWanderState()
    {
        if (Vector3.Distance(transform.position, nextDestination) < 1)
        {
            Debug.Log("Reached destination");
            currentState = FSMStates.Idle;
            timeInstance = elapsedTime;
            FindNextPoint();
        }
        else if (distanceToPlayer <= fleeDistance)
        {
            Debug.Log("Player entered distance");
            runDirection = (player.transform.position - transform.position).normalized * -1;
            currentState = FSMStates.Run;
        }
        FaceTarget(nextDestination);
        transform.position += transform.forward * Time.deltaTime * NPC_Speed;
    }

    void updateRunState()
    {
        Quaternion lookRotation = Quaternion.LookRotation(runDirection);
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, 10 * Time.deltaTime);
        transform.position += transform.forward * Time.deltaTime * NPC_Speed*2;
        if (distanceToPlayer >= fleeDistance*3)
        {
            currentState = FSMStates.Wander;
        }

    }

    void updateDeadState()
    {
        gameObject.SetActive(false);
        GameObject Explosion = Instantiate(explosionPrefab, transform.position + transform.forward, transform.rotation) as GameObject;
        Destroy(gameObject, 3);
    }

    void FindNextPoint()
    {
        nextDestination = wanderPoints[currentDestinationIndex].transform.position;

        currentDestinationIndex = (currentDestinationIndex + 1) % wanderPoints.Length;

    }

    void FaceTarget(Vector3 target)
    {
        Vector3 directionToTarget = (target - transform.position).normalized;
        Quaternion lookRotation = Quaternion.LookRotation(directionToTarget);
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, 10 * Time.deltaTime);
    }

    private void OnParticleCollision(GameObject other)
    {
        if (other.CompareTag("EnemyBullets") || other.CompareTag("PlayerBullets"))
        {
            currentState = FSMStates.Dead;
        }
        currentState = FSMStates.Dead;
    }

    private void OnCollisionEnter(Collision collision)
    {
        //currentState = FSMStates.Dead;
        // Deduct player hp
        currentState = FSMStates.Dead;
    }
}
