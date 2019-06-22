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
      towerPW = credentials('tower')
      sh 'tower-cli config host tower.andyneeb.com'
      sh 'tower-cli config verify_ssl false'
      withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'tower', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
          sh 'tower-cli config username $USERNAME && tower-cli config password $PASSWORD'
          }
      withEnv(["MVN_VERSION=$mvnVersion"]) {
          sh 'tower-cli workflow_job launch -W 58 --extra-vars=instance_name=dev --extra-vars=app_release=${MVN_VERSION} --extra-vars=app_stage=snapshot --monitor'
         }      
    }
}
