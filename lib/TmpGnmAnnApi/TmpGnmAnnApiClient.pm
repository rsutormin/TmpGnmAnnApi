package TmpGnmAnnApi::TmpGnmAnnApiClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

TmpGnmAnnApi::TmpGnmAnnApiClient

=head1 DESCRIPTION


A KBase module: TmpGnmAnnApi


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => TmpGnmAnnApi::TmpGnmAnnApiClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 get_combined_data

  $return = $obj->get_combined_data($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a TmpGnmAnnApi.GetCombinedDataParams
$return is a TmpGnmAnnApi.GenomeAnnotation_data
GetCombinedDataParams is a reference to a hash where the following keys are defined:
	ref has a value which is a TmpGnmAnnApi.ObjectReference
	exclude_genes has a value which is a TmpGnmAnnApi.boolean
	include_mrnas has a value which is a TmpGnmAnnApi.boolean
	exclude_cdss has a value which is a TmpGnmAnnApi.boolean
	include_features_by_type has a value which is a reference to a list where each element is a string
	exclude_protein_by_cds_id has a value which is a TmpGnmAnnApi.boolean
	include_mrna_ids_by_gene_id has a value which is a TmpGnmAnnApi.boolean
	exclude_cds_ids_by_gene_id has a value which is a TmpGnmAnnApi.boolean
	include_cds_id_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
	include_exons_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
	include_utr_by_utr_type_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
	exclude_summary has a value which is a TmpGnmAnnApi.boolean
ObjectReference is a string
boolean is an int
GenomeAnnotation_data is a reference to a hash where the following keys are defined:
	gene_type has a value which is a string
	mrna_type has a value which is a string
	cds_type has a value which is a string
	feature_types has a value which is a reference to a list where each element is a string
	feature_by_id_by_type has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.Feature_data
	protein_by_cds_id has a value which is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.Protein_data
	mrna_ids_by_gene_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
	cds_ids_by_gene_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
	cds_id_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a string
	exons_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a TmpGnmAnnApi.Exon_data
	utr_by_utr_type_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.UTR_data
	summary has a value which is a TmpGnmAnnApi.Summary_data
Feature_data is a reference to a hash where the following keys are defined:
	feature_id has a value which is a string
	feature_type has a value which is a string
	feature_function has a value which is a string
	feature_aliases has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
	feature_dna_sequence_length has a value which is an int
	feature_dna_sequence has a value which is a string
	feature_md5 has a value which is a string
	feature_locations has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
	feature_publications has a value which is a reference to a list where each element is a string
	feature_quality_warnings has a value which is a reference to a list where each element is a string
	feature_quality_score has a value which is a reference to a list where each element is a string
	feature_notes has a value which is a string
	feature_inference has a value which is a string
Region is a reference to a hash where the following keys are defined:
	contig_id has a value which is a string
	strand has a value which is a string
	start has a value which is an int
	length has a value which is an int
Protein_data is a reference to a hash where the following keys are defined:
	protein_id has a value which is a string
	protein_amino_acid_sequence has a value which is a string
	protein_function has a value which is a string
	protein_aliases has a value which is a reference to a list where each element is a string
	protein_md5 has a value which is a string
	protein_domain_locations has a value which is a reference to a list where each element is a string
Exon_data is a reference to a hash where the following keys are defined:
	exon_location has a value which is a TmpGnmAnnApi.Region
	exon_dna_sequence has a value which is a string
	exon_ordinal has a value which is an int
UTR_data is a reference to a hash where the following keys are defined:
	utr_locations has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
	utr_dna_sequence has a value which is a string
Summary_data is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	taxonomy_id has a value which is an int
	kingdom has a value which is a string
	scientific_lineage has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	organism_aliases has a value which is a reference to a list where each element is a string
	assembly_source has a value which is a string
	assembly_source_id has a value which is a string
	assembly_source_date has a value which is a string
	gc_content has a value which is a float
	dna_size has a value which is an int
	num_contigs has a value which is an int
	contig_ids has a value which is a reference to a list where each element is a string
	external_source has a value which is a string
	external_source_date has a value which is a string
	release has a value which is a string
	original_source_filename has a value which is a string
	feature_type_counts has a value which is a reference to a hash where the key is a string and the value is an int

</pre>

=end html

=begin text

$params is a TmpGnmAnnApi.GetCombinedDataParams
$return is a TmpGnmAnnApi.GenomeAnnotation_data
GetCombinedDataParams is a reference to a hash where the following keys are defined:
	ref has a value which is a TmpGnmAnnApi.ObjectReference
	exclude_genes has a value which is a TmpGnmAnnApi.boolean
	include_mrnas has a value which is a TmpGnmAnnApi.boolean
	exclude_cdss has a value which is a TmpGnmAnnApi.boolean
	include_features_by_type has a value which is a reference to a list where each element is a string
	exclude_protein_by_cds_id has a value which is a TmpGnmAnnApi.boolean
	include_mrna_ids_by_gene_id has a value which is a TmpGnmAnnApi.boolean
	exclude_cds_ids_by_gene_id has a value which is a TmpGnmAnnApi.boolean
	include_cds_id_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
	include_exons_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
	include_utr_by_utr_type_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
	exclude_summary has a value which is a TmpGnmAnnApi.boolean
ObjectReference is a string
boolean is an int
GenomeAnnotation_data is a reference to a hash where the following keys are defined:
	gene_type has a value which is a string
	mrna_type has a value which is a string
	cds_type has a value which is a string
	feature_types has a value which is a reference to a list where each element is a string
	feature_by_id_by_type has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.Feature_data
	protein_by_cds_id has a value which is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.Protein_data
	mrna_ids_by_gene_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
	cds_ids_by_gene_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
	cds_id_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a string
	exons_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a TmpGnmAnnApi.Exon_data
	utr_by_utr_type_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.UTR_data
	summary has a value which is a TmpGnmAnnApi.Summary_data
Feature_data is a reference to a hash where the following keys are defined:
	feature_id has a value which is a string
	feature_type has a value which is a string
	feature_function has a value which is a string
	feature_aliases has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
	feature_dna_sequence_length has a value which is an int
	feature_dna_sequence has a value which is a string
	feature_md5 has a value which is a string
	feature_locations has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
	feature_publications has a value which is a reference to a list where each element is a string
	feature_quality_warnings has a value which is a reference to a list where each element is a string
	feature_quality_score has a value which is a reference to a list where each element is a string
	feature_notes has a value which is a string
	feature_inference has a value which is a string
Region is a reference to a hash where the following keys are defined:
	contig_id has a value which is a string
	strand has a value which is a string
	start has a value which is an int
	length has a value which is an int
Protein_data is a reference to a hash where the following keys are defined:
	protein_id has a value which is a string
	protein_amino_acid_sequence has a value which is a string
	protein_function has a value which is a string
	protein_aliases has a value which is a reference to a list where each element is a string
	protein_md5 has a value which is a string
	protein_domain_locations has a value which is a reference to a list where each element is a string
Exon_data is a reference to a hash where the following keys are defined:
	exon_location has a value which is a TmpGnmAnnApi.Region
	exon_dna_sequence has a value which is a string
	exon_ordinal has a value which is an int
UTR_data is a reference to a hash where the following keys are defined:
	utr_locations has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
	utr_dna_sequence has a value which is a string
Summary_data is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	taxonomy_id has a value which is an int
	kingdom has a value which is a string
	scientific_lineage has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	organism_aliases has a value which is a reference to a list where each element is a string
	assembly_source has a value which is a string
	assembly_source_id has a value which is a string
	assembly_source_date has a value which is a string
	gc_content has a value which is a float
	dna_size has a value which is an int
	num_contigs has a value which is an int
	contig_ids has a value which is a reference to a list where each element is a string
	external_source has a value which is a string
	external_source_date has a value which is a string
	release has a value which is a string
	original_source_filename has a value which is a string
	feature_type_counts has a value which is a reference to a hash where the key is a string and the value is an int


=end text

=item Description

Retrieve any part of GenomeAnnotation. Please don't use this method in full mode (with all parts included) in cases
of large eukaryotic datasets. It may lead to out-of-memory errors.

=back

=cut

 sub get_combined_data
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_combined_data (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_combined_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_combined_data');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "TmpGnmAnnApi.get_combined_data",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_combined_data',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_combined_data",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_combined_data',
				       );
    }
}
 
  
sub status
{
    my($self, @args) = @_;
    if ((my $n = @args) != 0) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function status (received $n, expecting 0)");
    }
    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
        method => "TmpGnmAnnApi.status",
        params => \@args,
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'status',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method status",
                        status_line => $self->{client}->status_line,
                        method_name => 'status',
                       );
    }
}
   

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "TmpGnmAnnApi.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'get_combined_data',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method get_combined_data",
            status_line => $self->{client}->status_line,
            method_name => 'get_combined_data',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for TmpGnmAnnApi::TmpGnmAnnApiClient\n";
    }
    if ($sMajor == 0) {
        warn "TmpGnmAnnApi::TmpGnmAnnApiClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 ObjectReference

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 boolean

=over 4



=item Description

A boolean - 0 for false, 1 for true.
@range (0, 1)


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 Region

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
contig_id has a value which is a string
strand has a value which is a string
start has a value which is an int
length has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
contig_id has a value which is a string
strand has a value which is a string
start has a value which is an int
length has a value which is an int


=end text

=back



=head2 Feature_id_filters

=over 4



=item Description

*
* Filters passed to :meth:`get_feature_ids`
* @optional type_list region_list function_list alias_list


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
type_list has a value which is a reference to a list where each element is a string
region_list has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
function_list has a value which is a reference to a list where each element is a string
alias_list has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
type_list has a value which is a reference to a list where each element is a string
region_list has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
function_list has a value which is a reference to a list where each element is a string
alias_list has a value which is a reference to a list where each element is a string


=end text

=back



=head2 Feature_id_mapping

=over 4



=item Description

@optional by_type by_region by_function by_alias


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
by_type has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
by_region has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
by_function has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
by_alias has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
by_type has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
by_region has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
by_function has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
by_alias has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string


=end text

=back



=head2 Feature_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
feature_id has a value which is a string
feature_type has a value which is a string
feature_function has a value which is a string
feature_aliases has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
feature_dna_sequence_length has a value which is an int
feature_dna_sequence has a value which is a string
feature_md5 has a value which is a string
feature_locations has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
feature_publications has a value which is a reference to a list where each element is a string
feature_quality_warnings has a value which is a reference to a list where each element is a string
feature_quality_score has a value which is a reference to a list where each element is a string
feature_notes has a value which is a string
feature_inference has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
feature_id has a value which is a string
feature_type has a value which is a string
feature_function has a value which is a string
feature_aliases has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
feature_dna_sequence_length has a value which is an int
feature_dna_sequence has a value which is a string
feature_md5 has a value which is a string
feature_locations has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
feature_publications has a value which is a reference to a list where each element is a string
feature_quality_warnings has a value which is a reference to a list where each element is a string
feature_quality_score has a value which is a reference to a list where each element is a string
feature_notes has a value which is a string
feature_inference has a value which is a string


=end text

=back



=head2 Protein_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
protein_id has a value which is a string
protein_amino_acid_sequence has a value which is a string
protein_function has a value which is a string
protein_aliases has a value which is a reference to a list where each element is a string
protein_md5 has a value which is a string
protein_domain_locations has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
protein_id has a value which is a string
protein_amino_acid_sequence has a value which is a string
protein_function has a value which is a string
protein_aliases has a value which is a reference to a list where each element is a string
protein_md5 has a value which is a string
protein_domain_locations has a value which is a reference to a list where each element is a string


=end text

=back



=head2 Exon_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
exon_location has a value which is a TmpGnmAnnApi.Region
exon_dna_sequence has a value which is a string
exon_ordinal has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
exon_location has a value which is a TmpGnmAnnApi.Region
exon_dna_sequence has a value which is a string
exon_ordinal has a value which is an int


=end text

=back



=head2 UTR_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
utr_locations has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
utr_dna_sequence has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
utr_locations has a value which is a reference to a list where each element is a TmpGnmAnnApi.Region
utr_dna_sequence has a value which is a string


=end text

=back



=head2 Summary_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
taxonomy_id has a value which is an int
kingdom has a value which is a string
scientific_lineage has a value which is a reference to a list where each element is a string
genetic_code has a value which is an int
organism_aliases has a value which is a reference to a list where each element is a string
assembly_source has a value which is a string
assembly_source_id has a value which is a string
assembly_source_date has a value which is a string
gc_content has a value which is a float
dna_size has a value which is an int
num_contigs has a value which is an int
contig_ids has a value which is a reference to a list where each element is a string
external_source has a value which is a string
external_source_date has a value which is a string
release has a value which is a string
original_source_filename has a value which is a string
feature_type_counts has a value which is a reference to a hash where the key is a string and the value is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
taxonomy_id has a value which is an int
kingdom has a value which is a string
scientific_lineage has a value which is a reference to a list where each element is a string
genetic_code has a value which is an int
organism_aliases has a value which is a reference to a list where each element is a string
assembly_source has a value which is a string
assembly_source_id has a value which is a string
assembly_source_date has a value which is a string
gc_content has a value which is a float
dna_size has a value which is an int
num_contigs has a value which is an int
contig_ids has a value which is a reference to a list where each element is a string
external_source has a value which is a string
external_source_date has a value which is a string
release has a value which is a string
original_source_filename has a value which is a string
feature_type_counts has a value which is a reference to a hash where the key is a string and the value is an int


=end text

=back



=head2 GenomeAnnotation_data

=over 4



=item Description

gene_id is a feature id of a gene feature.
mrna_id is a feature id of a mrna feature.
cds_id is a feature id of a cds feature.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
gene_type has a value which is a string
mrna_type has a value which is a string
cds_type has a value which is a string
feature_types has a value which is a reference to a list where each element is a string
feature_by_id_by_type has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.Feature_data
protein_by_cds_id has a value which is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.Protein_data
mrna_ids_by_gene_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
cds_ids_by_gene_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
cds_id_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a string
exons_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a TmpGnmAnnApi.Exon_data
utr_by_utr_type_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.UTR_data
summary has a value which is a TmpGnmAnnApi.Summary_data

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
gene_type has a value which is a string
mrna_type has a value which is a string
cds_type has a value which is a string
feature_types has a value which is a reference to a list where each element is a string
feature_by_id_by_type has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.Feature_data
protein_by_cds_id has a value which is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.Protein_data
mrna_ids_by_gene_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
cds_ids_by_gene_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
cds_id_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a string
exons_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a TmpGnmAnnApi.Exon_data
utr_by_utr_type_by_mrna_id has a value which is a reference to a hash where the key is a string and the value is a reference to a hash where the key is a string and the value is a TmpGnmAnnApi.UTR_data
summary has a value which is a TmpGnmAnnApi.Summary_data


=end text

=back



=head2 GetCombinedDataParams

=over 4



=item Description

* Retrieve any part of GenomeAnnotation.
* Any of exclude_genes, include_mrnas and exclude_cdss flags override values listed in include_features_by_type.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ref has a value which is a TmpGnmAnnApi.ObjectReference
exclude_genes has a value which is a TmpGnmAnnApi.boolean
include_mrnas has a value which is a TmpGnmAnnApi.boolean
exclude_cdss has a value which is a TmpGnmAnnApi.boolean
include_features_by_type has a value which is a reference to a list where each element is a string
exclude_protein_by_cds_id has a value which is a TmpGnmAnnApi.boolean
include_mrna_ids_by_gene_id has a value which is a TmpGnmAnnApi.boolean
exclude_cds_ids_by_gene_id has a value which is a TmpGnmAnnApi.boolean
include_cds_id_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
include_exons_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
include_utr_by_utr_type_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
exclude_summary has a value which is a TmpGnmAnnApi.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ref has a value which is a TmpGnmAnnApi.ObjectReference
exclude_genes has a value which is a TmpGnmAnnApi.boolean
include_mrnas has a value which is a TmpGnmAnnApi.boolean
exclude_cdss has a value which is a TmpGnmAnnApi.boolean
include_features_by_type has a value which is a reference to a list where each element is a string
exclude_protein_by_cds_id has a value which is a TmpGnmAnnApi.boolean
include_mrna_ids_by_gene_id has a value which is a TmpGnmAnnApi.boolean
exclude_cds_ids_by_gene_id has a value which is a TmpGnmAnnApi.boolean
include_cds_id_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
include_exons_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
include_utr_by_utr_type_by_mrna_id has a value which is a TmpGnmAnnApi.boolean
exclude_summary has a value which is a TmpGnmAnnApi.boolean


=end text

=back



=cut

package TmpGnmAnnApi::TmpGnmAnnApiClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
