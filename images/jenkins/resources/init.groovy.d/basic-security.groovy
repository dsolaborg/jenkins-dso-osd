#!groovy

// Agent to Master System
import jenkins.security.s2m.AdminWhitelistRule
import hudson.security.csrf.DefaultCrumbIssuer
import jenkins.security.s2m.*
import jenkins.model.Jenkins
import jenkins.model.*
import hudson.security.*


def instance = Jenkins.getInstance()

// CSRF Protection
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))


println "--> creating local user 'admin'"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('','')
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
/////////////////////////////////////////////////////////////////

Jenkins jenkins = Jenkins.getInstance()

// Disable remoting
jenkins.getDescriptor("jenkins.CLI").get().setEnabled(false)

// Enable Agent to master security subsystem
jenkins.injector.getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false);

// Disable jnlp
jenkins.setSlaveAgentPort(-1);

// Disable old Non-Encrypted protocols
HashSet<String> newProtocols = new HashSet<>(jenkins.getAgentProtocols());
newProtocols.removeAll(Arrays.asList(
        "JNLP3-connect", "JNLP2-connect", "JNLP-connect", "CLI-connect"
));
jenkins.setAgentProtocols(newProtocols);

/////////////////////////////////////////////////////////////////
