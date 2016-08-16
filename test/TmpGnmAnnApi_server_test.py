# standard libraries
import ConfigParser
import functools
import logging
import os
import sys
import time
import unittest

# local imports
from biokbase.workspace.client import Workspace
from TmpGnmAnnApi.TmpGnmAnnApiImpl import TmpGnmAnnApi
from TmpGnmAnnApi.TmpGnmAnnApiServer import MethodContext

unittest.installHandler()

logging.basicConfig()
g_logger = logging.getLogger(__file__)
g_logger.propagate = False
log_handler = logging.StreamHandler(sys.stdout)
log_handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))
g_logger.addHandler(log_handler)
g_logger.setLevel(logging.INFO)

def log(func):
    if not g_logger:
        raise Exception("Missing logger for @log")

    ENTRY_MSG = "Entering {} with inputs {} {}"
    EXIT_MSG = "Exiting {}"

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        g_logger.info(ENTRY_MSG.format(func.__name__, args, kwargs))
        result = func(*args, **kwargs)
        g_logger.info(EXIT_MSG.format(func.__name__))
        return result

    return wrapper


class GenomeAnnotationAPITests(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        token = os.environ.get('KB_AUTH_TOKEN', None)
        # WARNING: don't call any logging methods on the context object,
        # it'll result in a NoneType error
        cls.ctx = MethodContext(None)
        cls.ctx.update({'token': token,
                        'provenance': [
                            {'service': 'TmpGnmAnnApi',
                             'method': 'please_never_use_it_in_production',
                             'method_params': []
                             }],
                        'authenticated': 1})

        config_file = os.environ.get('KB_DEPLOYMENT_CONFIG', None)
        config = ConfigParser.ConfigParser()
        config.read(config_file)
        cls.cfg = {n[0]: n[1] for n in config.items('TmpGnmAnnApi')}
        cls.ws = Workspace(cls.cfg['workspace-url'], token=token)
        cls.impl = TmpGnmAnnApi(cls.cfg)

        cls.ga_ref = "8020/81/1"
        cls.genome_ref = "8020/83/1"

    @classmethod
    def tearDownClass(cls):
        if hasattr(cls, 'wsName'):
            cls.ws.delete_workspace({'workspace': cls.wsName})
            print('Test workspace was deleted')

    def generatePesudoRandomWorkspaceName(self):
        if hasattr(self, 'wsName'):
            return self.wsName
        suffix = int(time.time() * 1000)
        wsName = "test_TmpGnmAnnApi_" + str(suffix)
        ret = self.ws.create_workspace({'workspace': wsName})
        self.wsName = wsName
        return wsName

    def getType(self, ref=None):
        return self.ws.get_object_info_new({"objects": [{"ref": ref}]})[0][2]

    @log
    def test_get_combined_data(self):
        inputs = {'ref': self.ga_ref}
        ret = self.impl.get_combined_data(self.ctx, inputs)
        self.assertGreater(len(ret[0]['feature_types']), 0, "ERROR: No feature types returned for {}".format(self.ga_ref))
        self.assertGreater(len(ret[0]['feature_by_id_by_type']), 0, "ERROR: No features returned for {}".format(self.ga_ref))
        self.assertGreater(len(ret[0]['feature_by_id_by_type']['gene']), 0, "ERROR: No genes returned for {}".format(self.ga_ref))
        self.assertGreater(len(ret[0]['feature_by_id_by_type']['CDS']), 0, "ERROR: No CDSs returned for {}".format(self.ga_ref))
        self.assertGreater(len(ret[0]['protein_by_cds_id']), 0, "ERROR: No proteins returned for {}".format(self.ga_ref))
        self.assertGreater(len(ret[0]['cds_ids_by_gene_id']), 0, "ERROR: No gene-CDS links returned for {}".format(self.ga_ref))
        self.assertTrue('summary' in ret[0] and ret[0]['summary'] is not None, "ERROR: No summary returned for {}".format(self.ga_ref))
