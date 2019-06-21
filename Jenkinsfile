node ('master') {
   def mvnHome
   stage('Preparation') { 
      git 'https://github.com/andyneeb/ansible-demo-app.git'
      mvnHome = tool 'M3'
   }

   stage('Build') {
      withEnv(["MVN_HOME=$mvnHome"]) {
        sh '"$MVN_HOME/bin/mvn" clean package'
      }
   }

   stage('Package') {
      withEnv(["MVN_HOME=$mvnHome"]) {
        sh '"$MVN_HOME/bin/mvn" deploy'
      }
   }

   stage('Stage') {
      mvnVersion = readMavenPom().getVersion()
      sh 'tower-cli config host tower.andyneeb.com'
      sh 'tower-cli config verify_ssl false'
      sh 'tower-cli config username jenkins'
      sh 'tower-cli config password jenkins'
      withEnv(["MVN_VERSION=$mvnVersion"]) {
          sh 'tower-cli workflow_job launch -J 58 --limit=dev --extra-vars=instance_name=dev --extra-vars=app_release=${MVN_VERSION} --extra-vars=app_stage=snapshot --monitor'
         }      
    }
}
