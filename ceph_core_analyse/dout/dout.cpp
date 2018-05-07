

CephContext* cct;

dout << "log" << dendl;

#define dout_context cct

#define dout(v) ldout((dout_context), v)
#define ldout(cct, v)  dout_impl(cct, dout_subsys, v) dout_prefix


#define dout_impl(cct, sub, v)                      \
    do {                                  \
        if (cct->_conf->subsys.should_gather(sub, v)) {         \
            if (0) {                                \
                char __array[((v >= -1) && (v <= 200)) ? 0 : -1] __attribute__((unused)); \
            }                                   \
            static size_t _log_exp_length = 80;                 \
            ceph::logging::Entry *_dout_e = cct->_log->create_entry(v, sub, &_log_exp_length);  \
            ostream _dout_os(&_dout_e->m_streambuf);                \
            static_assert(std::is_convertible<decltype(&*cct),          \
                    CephContext* >::value,        \
                    "provided cct must be compatible with CephContext*"); \
            auto _dout_cct = cct;                       \
            std::ostream* _dout = &_dout_os;



#define dendl dendl_impl

#define dendl_impl std::flush;              \
      _ASSERT_H->_log->submit_entry(_dout_e);       \
        }                       \
    } while (0)










#define derr lderr((dout_context))



