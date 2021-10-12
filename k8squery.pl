#!/usr/bin/env perl

use strict;
use warnings;
use Kubernetes::REST;
use Getopt::Long;
  
my $opt = {
    'api_token'        => 'bXRmZXF2OHg4TFJqTVJTcVB0OVcyNVowMEVtRitmUlRrN0lTY1VZcVhOVT0K',
    'api_endpoint'     => 'https://localhost:16443',
    'ssl_cert_file'    => "/var/snap/microk8s/current/certs/server.crt",
    'ssl_key_file'     => "/var/snap/microk8s/current/certs/server.key",
    'ssl_ca_file'      => "/var/snap/microk8s/current/certs/ca.crt",
#    ssl_cert_file      => "$ENV{HOME}/.minikube/client.crt",
#    ssl_key_file       => "$ENV{HOME}/.minikube/client.key",
#    ssl_ca_file        => "$ENV{HOME}/.minikube/ca.crt",
    'expand_conditions'=> 0,
};

GetOptions(
    $opt,
    'api_token=s',
    'api_endpoint=s',
    'ssl_cert_file=s',
    'ssl_key_file=s',
    'ssl_ca_file=s',
    'namespace=s',
    'expand_conditions=i',
);  

my $api = Kubernetes::REST->new(
  credentials => { token => $opt->{'api_token'} },
  server => { 
    endpoint          => $opt->{'api_endpoint'},
    ssl_verify_server => 1,
    ssl_cert_file     => $opt->{'ssl_cert_file'},
    ssl_key_file      => $opt->{'ssl_key_file'},
    ssl_ca_file       => $opt->{'ssl_ca_file'},
  },
);


# Need: Name of deployment, Images of each deployment, Date deployment was updated
my $DeploymentList = $api->Apps()->ListNamespacedDeployment(
    namespace => $opt->{'namespace'},
);
my $Deployment_header;
foreach my $Deployment (@{ $DeploymentList->{'items'} }) {
    if (!defined($Deployment_header)) {
        print("Deployment name\tLast state change\n");
        $Deployment_header = 1;
    }
    printf("%-15s\t%s\n",
        $Deployment->{'metadata'}{'name'},
        @{$Deployment->{'status'}{'conditions'}}[-1]->{'lastTransitionTime'},
    );

    if ($opt->{'expand_conditions'}) {
        my $DeploymentCondition_header;
        foreach my $DeploymentCondition (@{ $Deployment->{'status'}{'conditions'} } ) {
            if (!defined($DeploymentCondition_header)) {
                printf("\t- Condition\t%-47s\t%s\n",
                    'Message',
                    'Timestamp',
                );
                $DeploymentCondition_header = 1;
            }
            printf("\t\t\t%-47s\t%s\n",
                substr($DeploymentCondition->{'message'},0,47),
                $DeploymentCondition->{'lastTransitionTime'},
            );
        }
    }
    my $Container_header;
    foreach my $Container (@{ $Deployment->{'spec'}{'template'}{'spec'}{'containers'} } ) {
        if (!defined($Container_header)) {
            printf("\t- Container\t%-15s\t%s\n",
                'Name',
                'Image',
            );
            $Container_header = 1;
        }
        printf("\t\t\t%-15s\t%s\n",
            $Container->{'name'},
            $Container->{'image'}
        );
    }
}
